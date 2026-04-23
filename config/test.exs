import Config

ecto_repos = [Money.SQL.Repo]

Enum.each(ecto_repos, fn repo ->
  config :ex_money_sql, repo,
    username: "kip",
    database: "money_dev",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox
end)

config :ex_money_sql,
  ecto_repos: ecto_repos

config :ex_money,
  exchange_rates_retrieve_every: :never,
  log_failure: nil,
  log_info: nil

config :localize,
  default_locale: "en",
  supported_locales: ["en", "de"]

config :logger, level: :error
