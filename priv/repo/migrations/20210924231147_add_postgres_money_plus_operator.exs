defmodule Money.SQL.Repo.Migrations.AddPostgresMoneyPlusOperator do
  use Ecto.Migration

  def up do
    execute("""
    CREATE OR REPLACE FUNCTION money_add(money_1 money_with_currency, money_2 money_with_currency)
    RETURNS money_with_currency
    IMMUTABLE
    STRICT
    LANGUAGE plpgsql
    AS $$
      DECLARE
        currency char(3);
        addition numeric;
      BEGIN
        IF currency_code(money_1) = currency_code(money_2) THEN
          currency := currency_code(money_1);
          addition := amount(money_1) + amount(money_2);
          return row(currency, addition);
        ELSE
          RAISE EXCEPTION
            'Incompatible currency codes. Expected both currency codes to be %', currency_code(money_1)
            USING HINT = 'Please ensure both columns have the same currency code',
            ERRCODE = '22033';
        END IF;
      END;
    $$;
    """)

    execute("""
    CREATE OPERATOR + (
        leftarg = money_with_currency,
        rightarg = money_with_currency,
        procedure = money_add,
        commutator = +
    );
    """)
  end

  def down do
    execute("DROP OPERATOR + (money_with_currency, money_with_currency);")

    execute(
      "DROP FUNCTION IF EXISTS money_add(money_1 money_with_currency, money_2 money_with_currency);"
    )
  end
end