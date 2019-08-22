defmodule Money.SQL.Repo do
  use Ecto.Repo,
    otp_app: :ex_money_sql,
    adapter: Ecto.Adapters.Postgres

end

