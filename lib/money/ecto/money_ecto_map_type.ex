if Code.ensure_loaded?(Ecto.Type) do
  defmodule Money.Ecto.Map.Type do
    @moduledoc """
    Implements Ecto.Type behaviour for Money, where the underlying schema type
    is a map.

    This is the required option for databases such as MySQL that do not support
    composite types.

    In order to preserve precision, the amount is serialized as a string since the
    JSON representation of a numeric value is either an integer or a float.

    `Decimal.to_string/1` is not guaranteed to produce a string that will round-trip
    convert back to the identical number.
    """

    use Ecto.ParameterizedType

    defdelegate init(params), to: Money.Ecto.Composite.Type
    defdelegate cast(money), to: Money.Ecto.Composite.Type
    defdelegate cast(money, params), to: Money.Ecto.Composite.Type

    # New for ecto_sql 3.2
    defdelegate  embed_as(term, params), to: Money.Ecto.Composite.Type
    defdelegate  equal?(term1, term2, params), to: Money.Ecto.Composite.Type

    def type(_params) do
      :map
    end

    def load(money, loader \\ nil, params \\ [])

    def load(nil, _loader, _params) do
      {:ok, nil}
    end

    def load(%{"currency" => currency, "amount" => amount}, _loader, params) when is_binary(amount) do
      with {amount, ""} <- Cldr.Decimal.parse(amount),
           {:ok, currency} <- Money.validate_currency(currency) do
        {:ok, Money.new(currency, amount, params)}
      else
        _ -> :error
      end
    end

    def load(%{"currency" => currency, "amount" => amount}, _loader, params) when is_integer(amount) do
      with {:ok, currency} <- Money.validate_currency(currency) do
        {:ok, Money.new(currency, amount, params)}
      else
        _ -> :error
      end
    end

    def dump(money, dumper \\ nil, params \\ [])

    def dump(%Money{currency: currency, amount: %Decimal{} = amount}, _dumper, _params) do
      {:ok, %{"currency" => to_string(currency), "amount" => Decimal.to_string(amount)}}
    end

    def dump(nil, _, _) do
      {:ok, nil}
    end

    def dump(_, _, _) do
      :error
    end

  end
end
