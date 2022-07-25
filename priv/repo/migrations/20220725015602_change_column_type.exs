defmodule Money.SQL.Repo.Migrations.ChangeColumnType do
  use Ecto.Migration

  def up do
    execute("ALTER TYPE public.money_with_currency RENAME TO old_money_with_currency;")
    execute("CREATE TYPE public.money_with_currency AS (currency_code varchar, amount numeric);")
    execute("ALTER TABLE table_name RENAME COLUMN column_name TO old_column_name;")
    execute("ALTER TABLE table_name ADD COLUMN column_name money_with_currency;")

    execute(
      "UPDATE table_name SET column_name = ((old_column_name).currency_code, (old_column_name).amount)::money_with_currency;"
    )

    execute("ALTER TABLE table_name REMOVE COLUMN old_column_name;")
  end

  def down do
  end
end