if Code.ensure_loaded?(Ecto) do
  defmodule Mix.Tasks.Money.ChangeColumnType do
    use Mix.Task

    import Macro, only: [camelize: 1, underscore: 1]
    import Mix.Generator
    import Mix.Ecto, except: [migrations_path: 1]
    import Money.Migration

    @shortdoc "Changes a money_with_currency column from char(3) to varchar()"

    @moduledoc """
    Changes a money_with_currency column in a table from char(3) to
    varchar(). It will define the new type if required.
    """

    @doc false
    @dialyzer {:no_return, run: 1}

    def run(args) do
      no_umbrella!("money.change_column_type")
      repos = parse_repo(args)
      name = "change_column_type"

      Enum.each(repos, fn repo ->
        ensure_repo(repo, args)
        path = Path.relative_to(migrations_path(repo), Mix.Project.app_path())
        file = Path.join(path, "#{timestamp()}_#{underscore(name)}.exs")
        create_directory(path)

        unless length(args) == 2 do
          raise ArgumentError,
            "change_money_with_currency_type requires two arguments: a table name and a column name"
        end

        [table, column] = args

        assigns = [
          mod: Module.concat([repo, Migrations, camelize(name)]),
          table: table,
          column: column,
        ]

        up = get_sql("change_currency_to_varchar.sql", assigns)

        assigns =
          assigns
          |> Keyword.put(:up, up)
          |> Keyword.put(:down, nil)

        content =
          assigns
          |> migration_template
          |> format_string!

        create_file(file, content)

        if open?(file) and Mix.shell().yes?("Do you want to run this migration?") do
          Mix.Task.run("ecto.migrate", [repo])
        end
      end)
    end

    defp get_sql(file_name, assigns) do
      sql = Money.DDL.read_sql_file(:postgres, file_name)
      EEx.eval_string(sql, assigns)
    end

    defp timestamp do
      {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
      "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
    end

    defp pad(i) when i < 10, do: <<?0, ?0 + i>>
    defp pad(i), do: to_string(i)

    embed_template(:migration, """
    defmodule <%= inspect @mod %> do
      use Ecto.Migration

      def up do
        <%= Money.DDL.execute_each(@up) %>
      end

      def down do
        <%= @down %>
      end
    end
    """)
  end
end
