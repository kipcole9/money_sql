defmodule Money.SQL.Repo.Migrations.AddPostgresMoneyMinmaxFunctions do
  use Ecto.Migration

  def up do
    execute("""
    CREATE OR REPLACE FUNCTION money_min_state_function(agg_state money_with_currency, money money_with_currency)
    RETURNS money_with_currency
    IMMUTABLE
    STRICT
    LANGUAGE plpgsql
    AS $$
      DECLARE
        expected_currency varchar;
        aggregate numeric;
        min numeric;
      BEGIN
        IF currency_code(agg_state) IS NULL then
          expected_currency := currency_code(money);
          aggregate := 0;
        ELSE
          expected_currency := currency_code(agg_state);
          aggregate := amount(agg_state);
        END IF;

        IF currency_code(money) = expected_currency THEN
          IF amount(money) < aggregate THEN
            min := amount(money);
          ELSE
            min := aggregate;
          END IF;
          return row(expected_currency, min);
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
    CREATE OR REPLACE FUNCTION money_min_combine_function(agg_state1 money_with_currency, agg_state2 money_with_currency)
    RETURNS money_with_currency
    IMMUTABLE
    STRICT
    LANGUAGE plpgsql
    AS $$
      DECLARE
        min numeric;
      BEGIN
        IF currency_code(agg_state1) = currency_code(agg_state2) THEN
          IF amount(agg_state1) < amount(agg_state2) THEN
            min := amount(agg_state1);
          ELSE
            min := amount(agg_state2);
          END IF;
          return row(currency_code(agg_state1), min);
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
    CREATE AGGREGATE min(money_with_currency)
    (
      sfunc = money_min_state_function,
      stype = money_with_currency,
      combinefunc = money_min_combine_function,
      parallel = SAFE
    );
    """)

    execute("""
    CREATE OR REPLACE FUNCTION money_max_state_function(agg_state money_with_currency, money money_with_currency)
    RETURNS money_with_currency
    IMMUTABLE
    STRICT
    LANGUAGE plpgsql
    AS $$
      DECLARE
        expected_currency varchar;
        aggregate numeric;
        max numeric;
      BEGIN
        IF currency_code(agg_state) IS NULL then
          expected_currency := currency_code(money);
          aggregate := 0;
        ELSE
          expected_currency := currency_code(agg_state);
          aggregate := amount(agg_state);
        END IF;

        IF currency_code(money) = expected_currency THEN
          IF amount(money) > aggregate THEN
            max := amount(money);
          ELSE
            max := aggregate;
          END IF;
          return row(expected_currency, max);
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
    CREATE OR REPLACE FUNCTION money_max_combine_function(agg_state1 money_with_currency, agg_state2 money_with_currency)
    RETURNS money_with_currency
    IMMUTABLE
    STRICT
    LANGUAGE plpgsql
    AS $$
      DECLARE
        max numeric;
      BEGIN
        IF currency_code(agg_state1) = currency_code(agg_state2) THEN
          IF amount(agg_state1) > amount(agg_state2) THEN
            max := amount(agg_state1);
          ELSE
            max := amount(agg_state2);
          END IF;
          return row(currency_code(agg_state1), max);
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
    CREATE AGGREGATE max(money_with_currency)
    (
      sfunc = money_max_state_function,
      stype = money_with_currency,
      combinefunc = money_max_combine_function,
      parallel = SAFE
    );
    """)
  end

  def down do
    execute("DROP AGGREGATE IF EXISTS min(money_with_currency);")

    execute(
      "DROP FUNCTION IF EXISTS money_min_combine_function(agg_state1 money_with_currency, agg_state2 money_with_currency);"
    )

    execute(
      "DROP FUNCTION IF EXISTS money_min_state_function(agg_state money_with_currency, money money_with_currency);"
    )

    execute("DROP AGGREGATE IF EXISTS max(money_with_currency);")

    execute(
      "DROP FUNCTION IF EXISTS money_max_combine_function(agg_state1 money_with_currency, agg_state2 money_with_currency);"
    )

    execute(
      "DROP FUNCTION IF EXISTS money_max_state_function(agg_state money_with_currency, money money_with_currency);"
    )
  end
end