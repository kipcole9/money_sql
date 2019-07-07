use Mix.Config

config :ex_money, Money.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "kip",
  database: "money_dev",
  hostname: "localhost",
  pool_size: 10

config :ex_money, ecto_repos: [Money.Repo]

config :ex_money,
  exchange_rates_retrieve_every: :never,
  log_failure: nil,
  log_info: nil,
  default_cldr_backend: Test.Cldr
