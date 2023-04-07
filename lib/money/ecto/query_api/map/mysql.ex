if Code.ensure_loaded?(Ecto.Query.API) do
  defmodule Money.Ecto.Query.API.Map.MySQL do
    @moduledoc false

    @behaviour Money.Ecto.Query.API

    defmacro amount(field),
      do: quote(do: fragment(~S|CAST(JSON_EXTRACT(?, "$.amount") AS UNSIGNED)|, unquote(field)))

    defmacro currency_code(field),
      do: quote(do: fragment(~S|JSON_EXTRACT(?, "$.currency")|, unquote(field)))

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
    defmacro sum(field, false) do
      quote do: fragment(unquote(@sum_fragment), unquote(field), unquote(field), unquote(field))
    end

    defmacro sum(field, true),
      do: quote(do: type(sum(unquote(field), false), unquote(field)))
  end
end
