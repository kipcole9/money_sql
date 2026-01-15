if Code.ensure_loaded?(Ecto.Query.API) do
  defmodule Money.Ecto.Query.API do
    @moduledoc """
    Provides several helpers to query DB for the `Money` type.

    ### Usage

    In a module where you wish to use these helpers, add:

        use Money.Ecto.Query.API

    The default usage is designed to work with the `Money.Ecto.Composite.Type`
    implementation for Postgres databases. Altenative impkmentations can be
    made that comply with the `Money.Ecto.Query.API` behaviour. In that case

        use Money.Ecto.Query.API, adapter: MyAdapterModule

    See the Adapters section below.

    ### Implementation

    Under the hood it delegates to
    [`Ecto.Query.API.fragment/1`](https://hexdocs.pm/ecto/Ecto.Query.API.html#fragment/1-defining-custom-functions-using-macros-and-fragment),
    but might be helpful for compile-type sanity check for typos and
    better language server support.

    It is also designed to be an implementation-agnostic, meaning one can use
    these helpers without a necessity to explicitly specify a backing type.

    ### Adapters

    The default implementation recommends a `Composite` adapter, which is used by default.
    To use it with, say, `MySQL`, one should implement this behaviour for `MySQL` and declare
    the implementation as `use Money.Ecto.Query.API, adapter: MyImpl.MySQL.Adapter`

    Although the library provides the MySQL adapter too (Money.Ecto.Query.API.Map.MySQL)
    but it is not actively maintained, so use it on your own.

    If for some reason you use `Map` type with `Postgres`, helpers are still available
    with `use Money.Ecto.Query.API, adapter: Money.Ecto.Query.API.Map.Postgres`
    """

    @doc """
    Native implementation of how to retrieve `amount` from the DB.

    For `Postgres`, it delegates to the function on the composite type,
      for other implementation it should return a `Ecto.Query.API.fragment/1`.
    """
    @macrocallback amount(Macro.t()) :: Macro.t()

    @doc """
    Native implementation of how to retrieve `currency_code` from the DB.

    For `Postgres`, it delegates to the function on the composite type,
      for other implementation it should return a `Ecto.Query.API.fragment/1`.
    """
    @macrocallback currency_code(Macro.t()) :: Macro.t()

    @doc """
    Native implementation of how to `sum` several records having a field
    of the type `Money` in the DB.

    For `Postgres`, it delegates to the function on the composite type,
      for other implementation it should return a `Ecto.Query.API.fragment/1`.
    """
    @macrocallback sum(Macro.t(), cast? :: boolean()) :: Macro.t()

    @doc """
    Native implementation of how to `avg` (average) several records having a field
    of the type `Money` in the DB.

    For `Postgres`, it delegates to the function on the composite type,
      for other implementation it should return a `Ecto.Query.API.fragment/1`.
    """
    @macrocallback avg(Macro.t()) :: Macro.t()

    @doc """
    Cast decimal to the value accepted by the database.
    """
    @callback cast_decimal(Decimal.t()) :: any()

    @doc false
    defmacro __using__(opts \\ [])

    @doc false
    defmacro __using__([]),
      do: do_using(Money.Ecto.Query.API.Composite)

    @doc false
    defmacro __using__(adapter: adapter),
      do: do_using(adapter)

    defp do_using(adapter) do
      quote do
        import unquote(adapter)
        import Money.Ecto.Query.API
      end
    end

    @doc """
    `Ecto.Query.API` helper, allowing to filter records having the same currency.

    _Example:_

    ```elixir
    iex> Organization
    ...> |> where([o], currency_eq(o.payroll, :AUD))
    ...> |> select([o], o.payroll)
    ...> |> Repo.all()
    [Money.new(:AUD, "50"), Money.new(:AUD, "70")
    ```
    """
    defmacro currency_eq(field, currency) when is_atom(currency) do
      currency = currency |> to_string() |> String.upcase()
      do_currency_eq(field, currency)
    end

    defmacro currency_eq(field, currency) when is_binary(currency) do
      do_currency_eq(field, currency)
    end

    defp do_currency_eq(field, <<_::binary-size(3)>> = currency) do
      quote do: currency_code(unquote(field)) == ^unquote(currency)
    end

    @doc """
    `Ecto.Query.API` helper, allowing to filter records having the same amount.

    _Example:_

    ```elixir
    iex> Organization
    ...> |> where([o], amount_eq(o.payroll, 100))
    ...> |> select([o], o.payroll)
    ...> |> Repo.all()
    [Money.new(:EUR, "100"), Money.new(:USD, "100")
    ```
    """
    defmacro amount_eq(field, amount) when is_integer(amount) do
      quote do
        amount(unquote(field)) == ^unquote(amount)
      end
    end

    @doc """
    `Ecto.Query.API` helper, allowing to filter records having the same amount and currency.

    _Example:_

    ```elixir
    iex> Organization
    ...> |> where([o], money_eq(o.payroll, Money.new!(100, :USD)))
    ...> |> select([o], o.payroll)
    ...> |> Repo.all()
    [Money.new(:USD, "100"), Money.new(:USD, "100")]
    ```
    """
    defmacro money_eq(field, money) do
      quote do
        amount(unquote(field)) == ^cast_decimal(unquote(money).amount) and
          currency_code(unquote(field)) == ^to_string(unquote(money).currency)
      end
    end

    @doc """
    `Ecto.Query.API` helper, allowing to filter records having one
    of currencies given as an argument.

    _Example:_

    ```elixir
    iex> Organization
    ...> |> where([o], currency_in(o.payroll, [:USD, :EUR]))
    ...> |> select([o], o.payroll)
    ...> |> Repo.all()
    [Money.new(:EUR, "100"), Money.new(:USD, "100")]
    ```
    """
    defmacro currency_in(field, currencies) when is_list(currencies) do
      currencies = currencies |> Enum.map(&to_string/1) |> Enum.map(&String.upcase/1)

      quote do
        currency_code(unquote(field)) in ^unquote(currencies)
      end
    end

    @doc """
    `Ecto.Query.API` helper, allowing to filter records having the amount
    in the range given as an argument.

    Accepts `[min, max]`, `{min. max}`, and `min..max` as a range.

    _Example:_

    ```elixir
    iex> Organization
    ...> |> where([o], amount_in(o.payroll, 90..110))
    ...> |> select([o], o.payroll)
    ...> |> Repo.all()
    [Money.new(:EUR, "100"), Money.new(:USD, "100")]
    ```
    """
    defmacro amount_in(field, [min, max]),
      do: do_amount_in(field, min, max)

    defmacro amount_in(field, {min, max}),
      do: do_amount_in(field, min, max)

    defmacro amount_in(field, {:.., _, [min, max]}),
      do: do_amount_in(field, min, max)

    defmacro amount_in(field, {:..//, _, [min, max, 1]}),
      do: do_amount_in(field, min, max)

    defmacro amount_in(field, {:..//, _, [min, max, {:-, _, [1]}]}),
      do: do_amount_in(field, max, min)

    defmacro amount_in(field, {:..//, _, [_min, _max, step]}) do
      raise CompileError,
        file: __CALLER__.file,
        line: __CALLER__.line,
        description:
          "Ranges with a step (#{step}) are not supported for [#{Macro.to_string(field)}]"
    end

    defp do_amount_in(field, min, max) do
      quote do
        amount_ge(unquote(field), unquote(min)) and amount_le(unquote(field), unquote(max))
      end
    end

    @doc """
    `Ecto.Query.API` helper, allowing to filter records having the amount
    greater than or equal to the one given as an argument.

    _Example:_

    ```elixir
    iex> Organization
    ...> |> where([o], amount_ge(o.payroll, 90))
    ...> |> select([o], o.payroll)
    ...> |> Repo.all()
    [Money.new(:AUD, "90"), Money.new(:USD, "100")]
    ```
    """
    defmacro amount_ge(field, num) do
      quote do
        amount(unquote(field)) >= ^unquote(num)
      end
    end

    @doc """
    `Ecto.Query.API` helper, allowing to filter records having the amount
    less than or equal to the one given as an argument.

    _Example:_

    ```elixir
    iex> Organization
    ...> |> where([o], amount_le(o.payroll, 110))
    ...> |> select([o], o.payroll)
    ...> |> Repo.all()
    [Money.new(:EUR, "100"), Money.new(:USD, "110")]
    ```
    """
    defmacro amount_le(field, num) do
      quote do
        amount(unquote(field)) <= ^unquote(num)
      end
    end

    @doc """
    `Ecto.Query.API` helper, allowing to aggregate by currency, summing amount.
    For more sophisticated aggregation, resort to raw `fragment`.

    _Example:_

    ```elixir
    iex> Organization
    ...> |> where([o], o.name == ^"Lemon Inc.")
    ...> |> total_by([o], o.payroll)
    ...> |> Repo.all()
    [Money.new(:EUR, "100"), Money.new(:USD, "210")]
    ```
    """
    defmacro total_by(query, binding, field) do
      quote do
        unquote(query)
        |> where(unquote(binding), not is_nil(unquote(field)))
        |> group_by(unquote(binding), [currency_code(unquote(field))])
        |> select(unquote(binding), sum(unquote(field), true))
      end
    end

    @doc """
    `Ecto.Query.API` helper, allowing to aggregate by currency, suming amount.
    Same as `total_by/3`, but for the single currency only.

    _Example:_

    ```elixir
    iex> Organization
    ...> |> where([o], o.name == ^"Lemon Inc.")
    ...> |> total_by([o], o.payroll, :USD)
    ...> |> Repo.one()
    [Money.new(:USD, "210")]
    ```
    """
    defmacro total_by(query, binding, field, currency) do
      currency = currency |> to_string() |> String.upcase() |> List.wrap()

      quote do
        unquote(query)
        |> where(unquote(binding), not is_nil(unquote(field)))
        |> where(unquote(binding), currency_in(unquote(field), unquote(currency)))
        |> group_by(unquote(binding), [currency_code(unquote(field))])
        |> select(unquote(binding), sum(unquote(field), true))
      end
    end
  end
end
