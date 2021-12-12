defmodule Money.Ecto.Test do
  use ExUnit.Case

  describe "Money.Ecto.Composite.Type specific tests" do
    test "load a tuple with an unknown currency code produces an error" do
      assert Money.Ecto.Composite.Type.load({"ABC", 100}) == :error
    end

    test "load a tuple produces a Money struct" do
      assert Money.Ecto.Composite.Type.load({"USD", 100}) == {:ok, Money.new(:USD, 100)}
    end

    test "dump a money struct" do
      assert Money.Ecto.Composite.Type.dump(Money.new(:USD, 100)) ==
               {:ok, {"USD", Decimal.new(100)}}
    end
  end

  describe "Money.Ecto.Map.Type specific tests" do
    test "load a json map with a string amount produces a Money struct" do
      assert Money.Ecto.Map.Type.load(%{"currency" => "USD", "amount" => "100"}) ==
               {:ok, Money.new(:USD, 100)}
    end

    test "load a json map with a number amount produces a Money struct" do
      assert Money.Ecto.Map.Type.load(%{"currency" => "USD", "amount" => 100}) ==
               {:ok, Money.new(:USD, 100)}
    end

    test "load a json map with an unknown currency code produces an error" do
      assert Money.Ecto.Map.Type.load(%{"currency" => "AAA", "amount" => 100}) == :error
    end

    test "dump a money struct" do
      assert Money.Ecto.Map.Type.dump(Money.new(:USD, 100)) ==
               {:ok, %{"amount" => "100", "currency" => "USD"}}
    end
  end

  for ecto_type_module <- [Money.Ecto.Composite.Type, Money.Ecto.Map.Type] do
    test "#{inspect(ecto_type_module)}: dump anything other than a Money struct or a 2-tuple is an error" do
      assert unquote(ecto_type_module).dump(100) == :error
    end

    test "#{inspect(ecto_type_module)}: cast a map with the current structure but an empty amount" do
      assert unquote(ecto_type_module).cast(%{"currency" => "USD", "amount" => ""}) == {:ok, nil}
    end

    test "#{inspect(ecto_type_module)}: cast a money struct" do
      assert unquote(ecto_type_module).cast(Money.new(:USD, 100)) == {:ok, Money.new(:USD, 100)}
    end

    test "#{inspect(ecto_type_module)}: cast a map with string keys and values" do
      assert unquote(ecto_type_module).cast(%{"currency" => "USD", "amount" => "100"}) ==
               {:ok, Money.new(:USD, 100)}
    end

    test "#{inspect(ecto_type_module)}: cast a map with string keys and numeric amount" do
      assert unquote(ecto_type_module).cast(%{"currency" => "USD", "amount" => 100}) ==
               {:ok, Money.new(:USD, 100)}
    end

    test "#{inspect(ecto_type_module)}: cast a map with string keys, atom currency, and string amount" do
      assert unquote(ecto_type_module).cast(%{"currency" => :USD, "amount" => "100"}) ==
               {:ok, Money.new(100, :USD)}
    end

    test "#{inspect(ecto_type_module)}: cast a map with string keys, atom currency, and numeric amount" do
      assert unquote(ecto_type_module).cast(%{"currency" => :USD, "amount" => 100}) ==
               {:ok, Money.new(100, :USD)}
    end

    test "#{inspect(ecto_type_module)}: cast a map with string keys and invalid currency" do
      assert unquote(ecto_type_module).cast(%{"currency" => "AAA", "amount" => 100}) ==
               {:error, message: "The currency \"AAA\" is invalid"}
    end

    test "#{inspect(ecto_type_module)}: cast a map with atom keys and values" do
      assert unquote(ecto_type_module).cast(%{currency: "USD", amount: "100"}) ==
               {:ok, Money.new(100, :USD)}
    end

    test "#{inspect(ecto_type_module)}: cast a map with atom keys and numeric amount" do
      assert unquote(ecto_type_module).cast(%{currency: "USD", amount: 100}) ==
               {:ok, Money.new(100, :USD)}
    end

    test "#{inspect(ecto_type_module)}: cast a map with atom keys, atom currency, and numeric amount" do
      assert unquote(ecto_type_module).cast(%{currency: :USD, amount: 100}) ==
               {:ok, Money.new(100, :USD)}
    end

    test "#{inspect(ecto_type_module)}: cast a map with atom keys, atom currency, and string amount" do
      assert unquote(ecto_type_module).cast(%{currency: :USD, amount: "100"}) ==
               {:ok, Money.new(100, :USD)}
    end

    test "#{inspect(ecto_type_module)}: cast a map with atom keys and invalid currency" do
      assert unquote(ecto_type_module).cast(%{currency: "AAA", amount: 100}) ==
               {:error, message: "The currency \"AAA\" is invalid"}
    end

    test "#{inspect(ecto_type_module)}: cast a string that includes currency code and amount" do
      assert unquote(ecto_type_module).cast("100 USD") == {:ok, Money.new(100, :USD)}
      assert unquote(ecto_type_module).cast("USD 100") == {:ok, Money.new(100, :USD)}
    end

    test "#{inspect(ecto_type_module)}: cast a string that includes currency code and localised amount" do
      # "de"
      locale = Test.Cldr.get_locale()
      Test.Cldr.put_locale("de")
      assert unquote(ecto_type_module).cast("100,00 USD") == {:ok, Money.new("100,00", :USD)}
      Test.Cldr.put_locale(locale)
    end

    test "#{inspect(ecto_type_module)}: cast an invalid string is an error" do
      assert unquote(ecto_type_module).cast("100 USD and other stuff") ==
               {:error,
                message: "The currency \"USD and other stuff\" is unknown or not supported"}
    end

    test "#{inspect(ecto_type_module)}: cast anything else is an error" do
      assert unquote(ecto_type_module).cast(:atom) == :error
    end

    test "#{inspect(ecto_type_module)}: cast amount error does not raise" do
      assert unquote(ecto_type_module).cast(%{"currency" => "USD", "amount" => "yes"})
    end

    test "#{inspect(ecto_type_module)}: cast localized amount error does not raise" do
      Cldr.put_locale(Money.Cldr, "de")

      assert unquote(ecto_type_module).cast(%{currency: :NOK, amount: "218,75"}) ==
               {:ok, Money.from_float(:NOK, 218.75)}

      Cldr.put_locale(Money.Cldr, "en")
    end

    test "#{inspect(ecto_type_module)}: cast nil returns nil" do
      assert unquote(ecto_type_module).cast(nil) == {:ok, nil}
    end

    test "#{inspect(ecto_type_module)}: dumo nil returns nil" do
      assert unquote(ecto_type_module).dump(nil) == {:ok, nil}
    end

    test "#{inspect(ecto_type_module)}: load nil returns nil" do
      assert unquote(ecto_type_module).load(nil) == {:ok, nil}
    end

    test "#{inspect(ecto_type_module)}: equal? two equal money struct returns true" do
      assert unquote(ecto_type_module).equal?(
               Money.new(:USD, 100),
               Money.new(:USD, Decimal.new("100.0"))
             ) == true
    end

    test "#{inspect(ecto_type_module)}: equal? two unequal money struct returns false" do
      assert unquote(ecto_type_module).equal?(
               Money.new(:USD, 100),
               Money.new(:USD, Decimal.new("200.0"))
             ) == false
    end
  end
end
