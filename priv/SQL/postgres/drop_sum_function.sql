DROP AGGREGATE IF EXISTS sum(money_with_currency);


DROP FUNCTION IF EXISTS money_combine_function(agg_state1 money_with_currency, agg_state2 money_with_currency);


DROP FUNCTION IF EXISTS money_state_function(agg_state money_with_currency, money money_with_currency);
