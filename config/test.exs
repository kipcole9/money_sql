use Mix.Config

config :ex_money_sql, Money.SQL.Repo,
    username: "kip",
    database: "money_dev",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox

config :ex_money_sql,
  ecto_repos: [Money.SQL.Repo]

config :ex_money,
  exchange_rates_retrieve_every: :never,
  log_failure: nil,
  log_info: nil,
  default_cldr_backend: Test.Cldr

config :logger, level: :error
