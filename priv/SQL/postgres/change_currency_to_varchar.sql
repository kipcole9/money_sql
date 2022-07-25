ALTER TYPE public.money_with_currency RENAME TO old_money_with_currency;


CREATE TYPE public.money_with_currency AS (currency_code varchar, amount numeric);


ALTER TABLE <%= table %> RENAME COLUMN <%= column %> TO old_<%= column %>;


ALTER TABLE <%= table %> ADD COLUMN <%= column %> money_with_currency;


UPDATE <%= table %> SET <%= column %> = ((old_<%= column %>).currency_code, (old_<%= column %>).amount)::money_with_currency;


ALTER TABLE <%= table %> REMOVE COLUMN old_<%= column %>;