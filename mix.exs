defmodule Money.Sql.Mixfile do
  use Mix.Project

  @version "1.2.1"

  def project do
    [
      app: :ex_money_sql,
      version: @version,
      elixir: "~> 1.6",
      name: "Money",
      source_url: "https://github.com/kipcole9/money_sql",
      docs: docs(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore_warnings",
        plt_add_apps: ~w(inets jason mix ecto ecto_sql eex)a
      ],
      compilers: Mix.compilers()
    ]
  end

  defp description do
    "Money functions for the serialization a money data type."
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/kipcole9/money_sql",
        "Readme" => "https://github.com/kipcole9/money_sql/blob/v#{@version}/README.md",
        "Changelog" => "https://github.com/kipcole9/money_sql/blob/v#{@version}/CHANGELOG.md"
      },
      files: [
        "lib",
        "priv/SQL",
        "config",
        "mix.exs",
        "README.md",
        "CHANGELOG.md",
        "LICENSE.md"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md", "LICENSE.md"],
      main: "readme",
      logo: "logo.png",
      skip_undefined_reference_warnings_on: ["changelog"]
    ]
  end

  defp aliases do
    [
     test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp deps do
    [
      {:ex_money, "~> 5.0.1"},
      {:jason, "~> 1.0"},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.15"},
      {:benchee, "~> 1.0", optional: true, only: :dev},
      {:exprof, "~> 0.2", only: :dev, runtime: false},
      ex_doc_version(System.version())
    ]
  end

  defp ex_doc_version(version) do
    cond do
      Version.compare(version, "1.7.0") in [:gt, :eq] ->
        {:ex_doc, "~> 0.19", only: [:dev, :release]}

      Version.compare(version, "1.6.0") == :lt ->
        {:ex_doc, ">= 0.17.0 and < 0.18.0", only: [:dev, :release]}

      Version.compare(version, "1.7.0") == :lt ->
        {:ex_doc, ">= 0.18.0 and < 0.19.0", only: [:dev, :release]}
    end
  end

  defp elixirc_paths(:test), do: ["lib", "test", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "mix"]
  defp elixirc_paths(_), do: ["lib"]
end
