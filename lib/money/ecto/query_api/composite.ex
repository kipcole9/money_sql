if Code.ensure_loaded?(Ecto.Query.API) do
  defmodule Money.Ecto.Query.API.Composite do
    @moduledoc false

    @behaviour Money.Ecto.Query.API

    @impl Money.Ecto.Query.API
    defmacro amount(field),
      do: quote(do: fragment("amount(?)", unquote(field)))

    @impl Money.Ecto.Query.API
    defmacro currency_code(field),
      do: quote(do: fragment("currency_code(?)", unquote(field)))

    @impl Money.Ecto.Query.API
    defmacro sum(field, cast? \\ true)

    @impl Money.Ecto.Query.API
    defmacro sum(field, false),
      do: quote(do: fragment("sum(?)", unquote(field)))

    @impl Money.Ecto.Query.API
    defmacro sum(field, true),
      do: quote(do: type(sum(unquote(field)), unquote(field)))

    @impl Money.Ecto.Query.API
    defmacro avg(field),
      do: quote(do: fragment("avg(?)", unquote(field)))

    @impl Money.Ecto.Query.API
    def cast_decimal(%Decimal{} = d), do: d
  end
end
