DROP AGGREGATE IF EXISTS avg(money_with_currency);


DROP FUNCTION IF EXISTS money_avg_final_function(agg_state money_avg_state);


DROP FUNCTION IF EXISTS money_avg_combine_function(agg_state1 money_avg_state, agg_state2 money_avg_state);


DROP FUNCTION IF EXISTS money_avg_state_function(agg_state money_avg_state, money money_with_currency);


DROP TYPE IF EXISTS money_avg_state;