if Code.ensure_loaded?(Ecto.Query.API) do
  defmodule Money.Ecto.Query.API.Map.MySQL do
    @moduledoc false

    @behaviour Money.Ecto.Query.API

    @impl Money.Ecto.Query.API
    defmacro amount(field),
      do: quote(do: fragment(~S|CAST(JSON_EXTRACT(?, "$.amount") AS UNSIGNED)|, unquote(field)))

    @impl Money.Ecto.Query.API
    defmacro currency_code(field),
      do: quote(do: fragment(~S|JSON_EXTRACT(?, "$.currency")|, unquote(field)))

    @impl Money.Ecto.Query.API
    defmacro sum(field, cast? \\ true)

    @sum_fragment """
    IF(COUNT(DISTINCT(JSON_EXTRACT(?, "$.currency"))) < 2,
      JSON_OBJECT(
        "currency", JSON_EXTRACT(JSON_ARRAYAGG(JSON_EXTRACT(?, "$.currency")), "$[0]"),
        "amount", SUM(CAST(JSON_EXTRACT(?, "$.amount") AS UNSIGNED))
      ),
      NULL
    )
    """
    @impl Money.Ecto.Query.API
    defmacro sum(field, false) do
      quote do: fragment(unquote(@sum_fragment), unquote(field), unquote(field), unquote(field))
    end

    @impl Money.Ecto.Query.API
    defmacro sum(field, true),
      do: quote(do: type(sum(unquote(field), false), unquote(field)))

    @avg_fragment """
    IF(COUNT(DISTINCT(JSON_EXTRACT(?, "$.currency"))) < 2,
      JSON_OBJECT(
        "currency", JSON_EXTRACT(JSON_ARRAYAGG(JSON_EXTRACT(?, "$.currency")), "$[0]"),
        "amount", AVG(CAST(JSON_EXTRACT(?, "$.amount") AS UNSIGNED))
      ),
      NULL
    )
    """
    @impl Money.Ecto.Query.API
    defmacro avg(field) do
      quote do: fragment(unquote(@avg_fragment), unquote(field), unquote(field), unquote(field))
    end

    @impl Money.Ecto.Query.API
    def cast_decimal(%Decimal{} = d), do: Decimal.to_integer(d)
  end
end
