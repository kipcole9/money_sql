CREATE OR REPLACE FUNCTION money_negate(money_1 money_with_currency)
RETURNS money_with_currency
IMMUTABLE
STRICT
LANGUAGE plpgsql
SET search_path = ''
AS $$
    DECLARE
    currency varchar;
    addition numeric;
    BEGIN
    currency := currency_code(money_1);
    addition := amount(money_1) * -1;
    return row(currency, addition);
    END;
$$;


CREATE OPERATOR - (
    rightarg = money_with_currency,
    procedure = money_neg
);
