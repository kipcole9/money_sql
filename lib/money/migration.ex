defmodule Money.Migration do
  @moduledoc false

  def adjust_for_type(query, repo) do
    case postgres_money_with_currency_type(repo) do
      :varchar ->
        query
      :char_3 ->
        String.replace(query, "varchar", "char(3)")
      :not_postgres ->
        raise "Repo does not appear to be a Postgresql database"
      nil ->
        raise "No money_with_currency type is defined. " <>
          "Please run `mix money.gen.money_with_currency && mix ecto.migrate` first."
    end
  end

  def postgres_money_with_currency_type(repo) do
    query = read_sql_file("get_currency_code_type.sql")
    case repo.query!(query, [], log: false) do
      %Postgrex.Result{rows: [["character varying"]]} ->
        :varchar
      %Postgrex.Result{rows: [["character(3)"]]} ->
        :char_3
      %Postgrex.Result{rows: []} ->
        nil
      _other ->
        :not_postgres
    end
  end

  if Code.ensure_loaded?(Ecto.Migrator) && function_exported?(Ecto.Migrator, :migrations_path, 1) do
    def migrations_path(repo) do
      Ecto.Migrator.migrations_path(repo)
    end
  end

  if Code.ensure_loaded?(Mix.Ecto) && function_exported?(Mix.Ecto, :migrations_path, 1) do
    def migrations_path(repo) do
      Mix.Ecto.migrations_path(repo)
    end
  end

  if Code.ensure_loaded?(Code) && function_exported?(Code, :format_string!, 1) do
    @spec format_string!(String.t()) :: iodata()
    @dialyzer {:no_return, format_string!: 1}
    def format_string!(string) do
      Code.format_string!(string)
    end
  else
    @spec format_string!(String.t()) :: iodata()
    def format_string!(string) do
      string
    end
  end

  defp read_sql_file(file_name) do
    :code.priv_dir(:ex_money_sql)
    |> Path.join(["SQL", "/postgres", "/#{file_name}"])
    |> File.read!()
  end
end
