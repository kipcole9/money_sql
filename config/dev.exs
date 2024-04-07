import Config

config :ex_money,
  auto_start_exchange_rate_service: false,
  open_exchange_rates_app_id: {:system, "OPEN_EXCHANGE_RATES_APP_ID"},
  exchange_rates_retrieve_every: 300_000,
  callback_module: Money.ExchangeRates.Callback,
  log_failure: :warn,
  log_info: :info,
  log_success: :info,
  json_library: Jason,
  exchange_rates_cache: Money.ExchangeRates.Cache.Dets,
  default_cldr_backend: Money.Cldr

config :ex_money_sql, Money.SQL.Repo,
  username: "kip",
  database: "money_dev",
  hostname: "localhost",
  types: Money.Postgrex.Types

config :ex_money_sql,
  ecto_repos: [Money.SQL.Repo]
