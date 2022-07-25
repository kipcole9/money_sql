ALTER TYPE public.money_with_currency RENAME TO orig_money_with_currency;


CREATE TYPE public.money_with_currency AS (currency_code char(3), amount numeric);


ALTER TABLE <%= table %> RENAME COLUMN <%= column %> TO orig_<%= column %>;


ALTER TABLE <%= table %> ADD COLUMN <%= column %> money_with_currency;


UPDATE <%= table %> SET <%= column %> = ((orig_<%= column %>).currency_code, (orig_<%= column %>).amount)::money_with_currency;


ALTER TABLE <%= table %> REMOVE COLUMN orig_<%= column %>;