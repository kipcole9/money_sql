if Code.ensure_loaded?(Ecto.Type) do
  defmodule Money.Ecto.Postgres.Type do
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
    defdelegate init(opts), to: Money.Ecto.Composite.Type

    # When loading from the database

    @impl Ecto.ParameterizedType
    def load(tuple, loader \\ nil, params \\ [])

    def load(nil, _loader, _params) do
      {:ok, nil}
    end

    def load(%Money{} = money, _loader, params) do
      {:ok, Map.put(money, :format_options, params)}
    end

    def load(_, _, _) do
      :error
    end

    # Dumping to the database.  We make the assumption that
    # since we are dumping from %Money{} structs that the
    # data is ok.

    @impl Ecto.ParameterizedType
    def dump(money, dumper \\ nil, params \\ [])

    def dump(%Money{} = money, dumper, _params) do
      if embedded_dump?(dumper) do
        Money.Ecto.Map.Type.dump(money)
      else
        {:ok, money}
      end
    end

    def dump(nil, _, _) do
      {:ok, nil}
    end

    def dump(_, _, _) do
      :error
    end

    # Detects if we are being called on behalf the embedded dumper.
    # In this case, we want to produce a map that can be serialized
    # to JSON. See [papertrail issue](https://github.com/izelnakri/paper_trail/issues/230).

    defp embedded_dump?(nil) do
      false
    end

    defp embedded_dump?(dumper) when is_function(dumper, 2) do
      case Function.info(dumper, :name) do
        {:name, :"-embedded_dump/3-fun-0-"} ->
          Function.info(dumper, :module) == {:module, Ecto.Type}

        _other ->
          false
      end
    end

    # Casting in changesets

    def cast(money) do
      cast(money, [])
    end

    @impl Ecto.ParameterizedType
    defdelegate cast(value, params), to: Money.Ecto.Composite.Type

    # embed_as is set to :dump because if it is set to
    # `:self` then `cast/2` will be called when loading. And
    # since casting is locale-sensitive, the results may
    # not be correct due to variations in the decimal and grouping
    # separators for different locales. This is because when casting
    # we don't know if the data is coming from user input (and therefore should
    # be locale awware) or from some JSON serialization (in which
    # case it should not be locale aware).

    def embed_as(term), do: embed_as(term, [])

    @impl Ecto.ParameterizedType
    def embed_as(_term, _params), do: :dump

    def equal?(money1, money2), do: equal?(money1, money2, [])

    @impl Ecto.ParameterizedType
    def equal?(money1, money2, _params) do
      Money.equal?(money1, money2)
    end
  end
end
