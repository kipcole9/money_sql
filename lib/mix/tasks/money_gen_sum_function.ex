if Code.ensure_loaded?(Ecto) do
  defmodule Mix.Tasks.Money.Gen.Postgres.SumFunction do
    use Mix.Task

    import Mix.Generator
    import Mix.Ecto, except: [migrations_path: 1]
    import Macro, only: [camelize: 1, underscore: 1]
    import Money.Migration

    @shortdoc "Generates a migration to create a sum function for :money_with_currency"

    @moduledoc """
    Generates a migration to add a sum aggregate function
    to Postgres for the `money_with_currency` type.

    """

    @doc false
    @dialyzer {:no_return, run: 1}

    def run(args) do
      no_umbrella!("money.gen.postgres.sum_function")
      repos = parse_repo(args)
      name = "add_postgres_money_sum_function"

      Enum.each(repos, fn repo ->
        ensure_repo(repo, args)
        path = Path.relative_to(migrations_path(repo), Mix.Project.app_path())
        file = Path.join(path, "#{timestamp()}_#{underscore(name)}.exs")
        create_directory(path)

        assigns = [mod: Module.concat([repo, Migrations, camelize(name)])]

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
        <%= Money.DDL.execute_each(Money.DDL.define_sum_function) %>
      end

      def down do
        <%= Money.DDL.execute_each(Money.DDL.drop_sum_function) %>
      end
    end
    """)
  end
end
