if Code.ensure_loaded?(Ecto.Type) do
  defmodule Money.Ecto.Composite.Type do
    @moduledoc """
    Implements the Ecto.Type behaviour for a user-defined Postgres composite type
    called `:money_with_currency`.

    This is the preferred option for Postgres database since the serialized money
    amount is stored as a decimal number,
    """

    use Ecto.ParameterizedType

    @impl Ecto.ParameterizedType
    def type(_params) do
      :money_with_currency
    end

    def cast_type(opts \\ []) do
      Ecto.ParameterizedType.init(__MODULE__, opts)
    end

    @impl Ecto.ParameterizedType
    def init(opts) do
      opts
      |> Keyword.delete(:field)
      |> Keyword.delete(:schema)
      |> Keyword.delete(:default)
    end

    # When loading from the database

    @impl Ecto.ParameterizedType
    def load(tuple, loader \\ nil, params \\ [])

    def load(nil, _loader, _params) do
      {:ok, nil}
    end

    def load({currency, amount}, _loader, params) do
      currency = String.trim_trailing(currency)

      with {:ok, currency_code} <- Money.validate_currency(currency) do
        {:ok, Money.new(currency_code, amount, params)}
      else
        _ -> :error
      end
    end

    # Dumping to the database.  We make the assumption that
    # since we are dumping from %Money{} structs that the
    # data is ok

    @impl Ecto.ParameterizedType
    def dump(money, dumper \\ nil, params \\ [])

    def dump(%Money{} = money, _dumper, _params) do
      {:ok, {to_string(money.currency), money.amount}}
    end

    def dump(nil, _, _) do
      {:ok, nil}
    end

    def dump(_, _, _) do
      :error
    end

    # Casting in changesets

    def cast(money) do
      cast(money, [])
    end

    @impl Ecto.ParameterizedType
    def cast(nil, _params) do
      {:ok, nil}
    end

    def cast(%Money{} = money, _params) do
      {:ok, money}
    end

    def cast(%{"currency" => _, "amount" => ""}, _params) do
      {:ok, nil}
    end

    def cast(%{"currency" => _, "amount" => nil}, _params) do
      {:ok, nil}
    end

    def cast(%{"currency" => nil, "amount" => _amount}, _params) do
      {:error, exception: Money.UnknownCurrencyError, message: "Currency must not be `nil`"}
    end

    def cast(%{"currency" => currency, "amount" => amount}, params)
        when (is_binary(currency) or is_atom(currency)) and is_integer(amount) do
      with %{__struct__: Money} = money <- Money.new(currency, amount, params) do
        {:ok, money}
      else
        {:error, {exception, message}} -> {:error, exception: exception, message: message}
      end
    end

    def cast(%{"currency" => currency, "amount" => amount}, params)
        when (is_binary(currency) or is_atom(currency)) and is_binary(amount) do
      with %{__struct__: Money} = money <- Money.new(currency, amount, params) do
        {:ok, money}
      else
        {:error, {exception, message}} -> {:error, exception: exception, message: message}
      end
    end

    def cast(%{"currency" => currency, "amount" => %Decimal{} = amount}, params)
        when is_binary(currency) or is_atom(currency) do
      with %{__struct__: Money} = money <- Money.new(currency, amount, params) do
        {:ok, money}
      else
        {:error, {exception, message}} -> {:error, exception: exception, message: message}
      end
    end

    def cast(%{currency: currency, amount: amount}, params) do
      cast(%{"currency" => currency, "amount" => amount}, params)
    end

    def cast(string, params) when is_binary(string) do
      case Money.parse(string, params) do
        {:error, {exception, message}} -> {:error, exception: exception, message: message}
        money -> {:ok, money}
      end
    end

    def cast(_money, _params) do
      :error
    end

    def embed_as(term), do: embed_as(term, [])

    @impl Ecto.ParameterizedType
    def embed_as(_term, _params), do: :self

    def equal?(money1, money2), do: equal?(money1, money2, [])

    @impl Ecto.ParameterizedType
    def equal?(money1, money2, _params) do
      Money.equal?(money1, money2)
    end
  end
end
