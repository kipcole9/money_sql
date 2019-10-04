if Code.ensure_loaded?(Ecto.Type) do
  defmodule Money.Ecto.Composite.Type do
    @moduledoc """
    Implements the Ecto.Type behaviour for a user-defined Postgres composite type
    called `:money_with_currency`.

    This is the preferred option for Postgres database since the serialized money
    amount is stored as a decimal number,
    """

    @behaviour Ecto.Type

    def type do
      :money_with_currency
    end

    def blank?(_) do
      false
    end

    # When loading from the database
    def load({currency, amount}) do
      with {:ok, currency_code} <- validate_currency_for_load(currency) do
        {:ok, Money.new(currency_code, amount)}
      end
    end

    defp validate_currency_for_load(currency) do
      case Money.validate_currency(currency) do
        {:error, {_exception, _message}} -> :error
        {:ok, currency} -> {:ok, currency}
      end
    end

    # Dumping to the database.  We make the assumption that
    # since we are dumping from %Money{} structs that the
    # data is ok
    def dump(%Money{} = money) do
      {:ok, {to_string(money.currency), money.amount}}
    end

    def dump(_) do
      :error
    end

    # Casting in changesets
    def cast(%Money{} = money) do
      {:ok, money}
    end

    def cast(%{"currency" => _, "amount" => ""}) do
      {:ok, nil}
    end

    def cast(%{"currency" => currency, "amount" => amount})
        when (is_binary(currency) or is_atom(currency)) and is_integer(amount) do
      with decimal_amount <- Decimal.new(amount),
           {:ok, currency_code} <- validate_currency_for_cast(currency) do
        {:ok, Money.new(currency_code, decimal_amount)}
      end
    end

    def cast(%{"currency" => currency, "amount" => amount})
        when (is_binary(currency) or is_atom(currency)) and is_binary(amount) do
      with {:ok, amount} <- Decimal.parse(amount),
           {:ok, currency_code} <- validate_currency_for_cast(currency) do
        {:ok, Money.new(currency_code, amount)}
      end
    end

    def cast(%{"currency" => currency, "amount" => %Decimal{} = amount})
        when is_binary(currency) or is_atom(currency) do
      with {:ok, currency_code} <- validate_currency_for_cast(currency) do
        {:ok, Money.new(currency_code, amount)}
      end
    end

    def cast(%{currency: currency, amount: amount}) do
      cast(%{"currency" => currency, "amount" => amount})
    end

    def cast(string) when is_binary(string) do
      case Money.parse(string) do
        {:error, _} -> :error
        money -> {:ok, money}
      end
    end

    def cast(_money) do
      :error
    end

    defp validate_currency_for_cast(currency) do
      case Money.validate_currency(currency) do
        {:error, {_exception, message}} -> {:error, [message: message]}
        {:ok, currency} -> {:ok, currency}
      end
    end
  end
end
