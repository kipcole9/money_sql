if Code.ensure_loaded?(Ecto.Query.API) do
  defmodule Money.Ecto.Query.API.Postgres do
    @moduledoc false

    @behaviour Money.Ecto.Query.API

    defmacro amount(field),
      do: quote(do: fragment("amount(?)", unquote(field)))

    defmacro currency_code(field),
      do: quote(do: fragment("currency_code(?)", unquote(field)))

    defmacro sum(field, cast? \\ true)

    defmacro sum(field, false),
      do: quote(do: fragment("sum(?)", unquote(field)))

    defmacro sum(field, true),
      do: quote(do: type(sum(unquote(field)), unquote(field)))
  end
end
