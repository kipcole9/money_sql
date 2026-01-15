CREATE TYPE public.money_avg_state AS (currency_code varchar, sum numeric, count bigint);


CREATE OR REPLACE FUNCTION money_avg_state_function(agg_state money_avg_state, money money_with_currency)
RETURNS money_avg_state
IMMUTABLE
LANGUAGE plpgsql
AS $$
  DECLARE
    expected_currency varchar;
    new_sum numeric;
    new_count bigint;
  BEGIN
    IF agg_state IS NULL OR agg_state.currency_code IS NULL THEN
      expected_currency := currency_code(money);
      new_sum := amount(money);
      new_count := 1;
    ELSE
      expected_currency := agg_state.currency_code;
      IF currency_code(money) = expected_currency THEN
        new_sum := agg_state.sum + amount(money);
        new_count := agg_state.count + 1;
      ELSE
        RAISE EXCEPTION
          'Incompatible currency codes. Expected all currency codes to be %', expected_currency
          USING HINT = 'Please ensure all columns have the same currency code',
          ERRCODE = '22033';
      END IF;
    END IF;

    RETURN ROW(expected_currency, new_sum, new_count)::money_avg_state;
  END;
$$;


CREATE OR REPLACE FUNCTION money_avg_combine_function(agg_state1 money_avg_state, agg_state2 money_avg_state)
RETURNS money_avg_state
IMMUTABLE
LANGUAGE plpgsql
AS $$
  BEGIN
    IF agg_state1 IS NULL THEN
      RETURN agg_state2;
    ELSIF agg_state2 IS NULL THEN
      RETURN agg_state1;
    ELSIF agg_state1.currency_code = agg_state2.currency_code THEN
      RETURN ROW(agg_state1.currency_code,
                 agg_state1.sum + agg_state2.sum,
                 agg_state1.count + agg_state2.count)::money_avg_state;
    ELSE
      RAISE EXCEPTION
        'Incompatible currency codes. Expected all currency codes to be %', agg_state1.currency_code
        USING HINT = 'Please ensure all columns have the same currency code',
        ERRCODE = '22033';
    END IF;
  END;
$$;


CREATE OR REPLACE FUNCTION money_avg_final_function(agg_state money_avg_state)
RETURNS money_with_currency
IMMUTABLE
LANGUAGE plpgsql
AS $$
  BEGIN
    IF agg_state IS NULL OR agg_state.count = 0 THEN
      RETURN NULL;
    ELSE
      RETURN ROW(agg_state.currency_code, agg_state.sum / agg_state.count)::money_with_currency;
    END IF;
  END;
$$;


CREATE OR REPLACE AGGREGATE avg(money_with_currency)
(
  sfunc = money_avg_state_function,
  stype = money_avg_state,
  combinefunc = money_avg_combine_function,
  finalfunc = money_avg_final_function,
  parallel = SAFE
);