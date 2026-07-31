defmodule Money.MigrationTest do
  use Money.SQL.RepoCase, async: true

  # `postgres_money_with_currency_type/1` branches on what the database
  # reports for the currency_code column, and `adjust_for_type/2` rewrites
  # the generated SQL to match. Only one of those states can exist in the
  # test database at a time, so the branches are driven by stub repos that
  # return each shape. The `:varchar` case is additionally checked against
  # the real repo below.
  defmodule VarcharRepo do
    @moduledoc false
    def query!(_query, _params, _options), do: %{rows: [["character varying"]]}
  end

  defmodule Char3Repo do
    @moduledoc false
    def query!(_query, _params, _options), do: %{rows: [["character(3)"]]}
  end

  defmodule NoTypeRepo do
    @moduledoc false
    def query!(_query, _params, _options), do: %{rows: []}
  end

  defmodule NotPostgresRepo do
    @moduledoc false
    def query!(_query, _params, _options), do: %{rows: [["something else"]]}
  end

  describe "postgres_money_with_currency_type/1" do
    test "reports :varchar against the real database" do
      assert Money.Migration.postgres_money_with_currency_type(Money.SQL.Repo) == :varchar
    end

    test "reports each column type" do
      assert Money.Migration.postgres_money_with_currency_type(VarcharRepo) == :varchar
      assert Money.Migration.postgres_money_with_currency_type(Char3Repo) == :char_3
    end

    test "reports nil when the type is not installed" do
      assert Money.Migration.postgres_money_with_currency_type(NoTypeRepo) == nil
    end

    test "reports :not_postgres for an unrecognised result" do
      assert Money.Migration.postgres_money_with_currency_type(NotPostgresRepo) == :not_postgres
    end
  end

  describe "adjust_for_type/2" do
    @query "CREATE FUNCTION f(code varchar) RETURNS varchar"

    test "leaves the query alone when the column is varchar" do
      assert Money.Migration.adjust_for_type(@query, VarcharRepo) == @query
    end

    # Databases created before the type changed to varchar still use
    # char(3); the generated function signatures have to match or the
    # migration fails.
    test "rewrites varchar to char(3) for an older database" do
      assert Money.Migration.adjust_for_type(@query, Char3Repo) ==
               "CREATE FUNCTION f(code char(3)) RETURNS char(3)"
    end

    test "raises when the type has not been created" do
      assert_raise RuntimeError, ~r/No money_with_currency type is defined/, fn ->
        Money.Migration.adjust_for_type(@query, NoTypeRepo)
      end
    end

    test "raises when the repo is not PostgreSQL" do
      assert_raise RuntimeError, ~r/does not appear to be a Postgresql database/, fn ->
        Money.Migration.adjust_for_type(@query, NotPostgresRepo)
      end
    end
  end

  describe "migrations_path/1" do
    test "returns the repository's migrations directory" do
      path = Money.Migration.migrations_path(Money.SQL.Repo)

      assert is_binary(path)
      assert String.ends_with?(path, "migrations")
    end
  end

  describe "format_string!/1" do
    test "formats generated migration source" do
      assert Money.Migration.format_string!("def   up do\n:ok\nend") ==
               "def up do\n  :ok\nend"
    end

    test "returns a binary rather than iodata" do
      assert is_binary(Money.Migration.format_string!("x=1"))
    end
  end
end
