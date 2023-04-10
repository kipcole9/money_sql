if Code.ensure_loaded?(Ecto.Query.API) do
  defmodule Money.Ecto.Query.API.Map.Postgres do
    @moduledoc false

    @behaviour Money.Ecto.Query.API

    @impl Money.Ecto.Query.API
    defmacro amount(field),
      do: quote(do: fragment(~S|(?->>'amount')::int|, unquote(field)))

    @impl Money.Ecto.Query.API
    defmacro currency_code(field),
      do: quote(do: fragment(~S|?->>'currency'|, unquote(field)))

    @impl Money.Ecto.Query.API
    defmacro sum(field, cast? \\ true)

    @sum_fragment """
    CASE COUNT(DISTINCT(?->>'currency'))
    WHEN 0 THEN JSON_BUILD_OBJECT('currency', NULL, 'amount', 0)
    WHEN 1 THEN JSON_BUILD_OBJECT('currency', MAX(?->>'currency'), 'amount', SUM((?->>'amount')::int))
    ELSE NULL
    END
    """
    @impl Money.Ecto.Query.API
    defmacro sum(field, false) do
      quote do: fragment(unquote(@sum_fragment), unquote(field), unquote(field), unquote(field))
    end

    @impl Money.Ecto.Query.API
    defmacro sum(field, true),
      do: quote(do: type(sum(unquote(field), false), unquote(field)))

    @impl Money.Ecto.Query.API
    def cast_decimal(%Decimal{} = d), do: Decimal.to_integer(d)
  end
end
