defmodule Money.Ecto.EdgeCaseTest do
  use ExUnit.Case, async: true

  alias Money.Ecto.Composite.Type, as: Composite
  alias Money.Ecto.Map.Type, as: Map

  @params []

  describe "composite type load" do
    test "trims the padding of a char(3) currency column" do
      assert {:ok, money} = Composite.load({"USD ", Decimal.new(100)}, nil, [])
      assert money.currency == :USD
    end

    test "refuses an unknown currency" do
      assert Composite.load({"AAA", Decimal.new(100)}, nil, []) == :error
    end

    test "loads nil and refuses a non-tuple" do
      assert Composite.load(nil, nil, []) == {:ok, nil}
      assert Composite.load("USD 100", nil, []) == :error
    end
  end

  describe "composite type dump" do
    test "dumps to a currency and amount tuple" do
      assert {:ok, {"USD", amount}} = Composite.dump(Money.new(:USD, 100), nil, [])
      assert Decimal.equal?(amount, Decimal.new(100))
    end

    test "dumps nil and refuses a non-money" do
      assert Composite.dump(nil, nil, []) == {:ok, nil}
      assert Composite.dump("not money", nil, []) == :error
    end
  end

  describe "composite type cast" do
    test "a nil currency is reported as unknown" do
      assert {:error, exception: Money.UnknownCurrencyError, message: _} =
               Composite.cast(%{"currency" => nil, "amount" => 100}, @params)
    end

    test "an empty or nil amount casts to nil" do
      assert Composite.cast(%{"currency" => "USD", "amount" => ""}, @params) == {:ok, nil}
      assert Composite.cast(%{"currency" => "USD", "amount" => nil}, @params) == {:ok, nil}
    end

    test "a decimal amount casts" do
      assert {:ok, money} =
               Composite.cast(%{"currency" => "USD", "amount" => Decimal.new(5)}, @params)

      assert Decimal.equal?(money.amount, Decimal.new(5))
    end

    test "an atom-keyed map casts" do
      assert {:ok, money} = Composite.cast(%{currency: :USD, amount: 100}, @params)
      assert money.currency == :USD
    end

    test "a string is parsed" do
      assert {:ok, money} = Composite.cast("USD 100", @params)
      assert money.currency == :USD
    end

    test "an unparseable string is an error" do
      assert {:error, _} = Composite.cast("not money at all", @params)
    end

    test "casts nil and refuses an unsupported term" do
      assert Composite.cast(nil, @params) == {:ok, nil}
      assert Composite.cast(42, @params) == :error
    end
  end

  describe "composite type equality and embedding" do
    test "equal amounts compare equal" do
      assert Composite.equal?(Money.new(:USD, 100), Money.new(:USD, 100))
      refute Composite.equal?(Money.new(:USD, 100), Money.new(:USD, 200))
    end

    test "embeds the dumped form" do
      assert Composite.embed_as(:json) == :dump
      assert Composite.embed_as(:json, @params) == :dump
    end
  end

  describe "map type" do
    test "loads the legacy currency_code key" do
      assert {:ok, money} = Map.load(%{"currency_code" => "USD", "amount" => "100"}, nil, [])
      assert money.currency == :USD
    end

    test "loads an integer amount" do
      assert {:ok, money} = Map.load(%{"currency" => "USD", "amount" => 100}, nil, [])
      assert Decimal.equal?(money.amount, Decimal.new(100))
    end

    test "refuses an unknown currency and a non-map" do
      assert Map.load(%{"currency" => "AAA", "amount" => "100"}, nil, []) == :error
      assert Map.load("USD", nil, []) == :error
    end

    test "dumps the amount as a string to preserve precision" do
      assert {:ok, %{"currency" => "USD", "amount" => "100"}} =
               Map.dump(Money.new(:USD, 100), nil, [])
    end

    test "loads and dumps nil, refuses a non-money" do
      assert Map.load(nil, nil, []) == {:ok, nil}
      assert Map.dump(nil, nil, []) == {:ok, nil}
      assert Map.dump("not money", nil, []) == :error
    end

    test "delegates equality and embedding to the composite type" do
      assert Map.equal?(Money.new(:USD, 100), Money.new(:USD, 100))
      assert Map.embed_as(:json) == :dump
    end
  end

  describe "query adapters cast_decimal/1" do
    test "the map adapters convert a decimal to an integer" do
      assert Money.Ecto.Query.API.Map.Postgres.cast_decimal(Decimal.new(100)) == 100
      assert Money.Ecto.Query.API.Map.MySQL.cast_decimal(Decimal.new(100)) == 100
    end
  end
end
