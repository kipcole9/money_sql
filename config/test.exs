import Config

ecto_repos = [Money.SQL.Repo]

# Connection settings follow the libpq environment variables so that CI
# (a service container with a password) and local development (trust
# auth as the current user) both work without configuration changes.
Enum.each(ecto_repos, fn repo ->
  config :ex_money_sql, repo,
    username: System.get_env("PGUSER", System.get_env("USER")),
    password: System.get_env("PGPASSWORD"),
    database: System.get_env("PGDATABASE", "money_dev"),
    hostname: System.get_env("PGHOST", "localhost"),
    port: String.to_integer(System.get_env("PGPORT", "5432")),
    pool: Ecto.Adapters.SQL.Sandbox
end)

config :ex_money_sql,
  ecto_repos: ecto_repos

config :ex_money,
  exchange_rates_retrieve_every: :never,
  log_failure: nil,
  log_info: nil

config :localize,
  default_locale: :en,
  allow_runtime_locale_download: true

config :postgrex, :json_library, JSON

config :logger, level: :error
