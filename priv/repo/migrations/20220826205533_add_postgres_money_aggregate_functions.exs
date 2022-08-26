defmodule Money.SQL.Repo.Migrations.AddPostgresMoneyAggregateFunctions do
  use Ecto.Migration

  def up do
    execute("""
    CREATE OR REPLACE FUNCTION money_state_function(agg_state money_with_currency, money money_with_currency)
    RETURNS money_with_currency
    IMMUTABLE
    STRICT
    LANGUAGE plpgsql
    AS $$
      DECLARE
        expected_currency varchar;
        aggregate numeric;
        addition numeric;
      BEGIN
        if currency_code(agg_state) IS NULL then
          expected_currency := currency_code(money);
          aggregate := 0;
        else
          expected_currency := currency_code(agg_state);
          aggregate := amount(agg_state);
        end if;

        IF currency_code(money) = expected_currency THEN
          addition := aggregate + amount(money);
          return row(expected_currency, addition);
        ELSE
          RAISE EXCEPTION
            'Incompatible currency codes. Expected all currency codes to be %', expected_currency
            USING HINT = 'Please ensure all columns have the same currency code',
            ERRCODE = '22033';
        END IF;
      END;
    $$;
    """)

    execute("""
    CREATE OR REPLACE FUNCTION money_combine_function(agg_state1 money_with_currency, agg_state2 money_with_currency)
    RETURNS money_with_currency
    IMMUTABLE
    STRICT
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF currency_code(agg_state1) = currency_code(agg_state2) THEN
          return row(currency_code(agg_state1), amount(agg_state1) + amount(agg_state2));
        ELSE
          RAISE EXCEPTION
            'Incompatible currency codes. Expected all currency codes to be %', expected_currency
            USING HINT = 'Please ensure all columns have the same currency code',
            ERRCODE = '22033';
        END IF;
      END;
    $$;
    """)

    execute("""
    CREATE AGGREGATE sum(money_with_currency)
    (
      sfunc = money_state_function,
      stype = money_with_currency,
      combinefunc = money_combine_function,
      parallel = SAFE
    );
    """)
  end

  def down do
    execute("DROP AGGREGATE IF EXISTS sum(money_with_currency);")

    execute(
      "DROP FUNCTION IF EXISTS money_combine_function(agg_state1 money_with_currency, agg_state2 money_with_currency);"
    )

    execute(
      "DROP FUNCTION IF EXISTS money_state_function(agg_state money_with_currency, money money_with_currency);"
    )
  end
end