DROP AGGREGATE IF EXISTS max(money_with_currency);


DROP FUNCTION IF EXISTS money_max_combine_function(agg_state1 money_with_currency, agg_state2 money_with_currency);


DROP FUNCTION IF EXISTS money_max_state_function(agg_state money_with_currency, money money_with_currency);


DROP AGGREGATE IF EXISTS min(money_with_currency);


DROP FUNCTION IF EXISTS money_min_combine_function(agg_state1 money_with_currency, agg_state2 money_with_currency);


DROP FUNCTION IF EXISTS money_min_state_function(agg_state money_with_currency, money money_with_currency);
