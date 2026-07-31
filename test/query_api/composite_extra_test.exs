defmodule Money.Query.API.CompositeExtraTest do
  use Money.SQL.RepoCase
  use Money.Ecto.Query.API, adapter: Money.Ecto.Query.API.Composite

  # Covers the Query.API surface the existing composite tests do not
  # reach: the comparison macros, `avg`, the uncast `sum`, and the range
  # forms of `amount_in`.
  setup do
    for {amount, name} <- [{100, "A"}, {200, "B"}, {300, "C"}] do
      {:ok, _} = Repo.insert(%Organization{payroll: Money.new(:USD, amount), name: name})
    end

    :ok
  end

  defp amounts(query) do
    query
    |> select([o], o.payroll)
    |> Repo.all()
    |> Enum.map(&Decimal.to_integer(&1.amount))
    |> Enum.sort()
  end

  describe "comparison macros" do
    test "amount_ge selects amounts at or above the bound" do
      assert amounts(where(Organization, [o], amount_ge(o.payroll, 200))) == [200, 300]
    end

    test "amount_le selects amounts at or below the bound" do
      assert amounts(where(Organization, [o], amount_le(o.payroll, 200))) == [100, 200]
    end

    test "amount_ge and amount_le accept a decimal bound" do
      assert amounts(where(Organization, [o], amount_ge(o.payroll, Decimal.new(300)))) == [300]
      assert amounts(where(Organization, [o], amount_le(o.payroll, Decimal.new(100)))) == [100]
    end
  end

  describe "amount_in accepts each range form" do
    test "a two-element list" do
      assert amounts(where(Organization, [o], amount_in(o.payroll, [100, 200]))) == [100, 200]
    end

    test "a tuple" do
      assert amounts(where(Organization, [o], amount_in(o.payroll, {200, 300}))) == [200, 300]
    end

    test "a range" do
      assert amounts(where(Organization, [o], amount_in(o.payroll, 100..200))) == [100, 200]
    end

    test "a range with an explicit step of one" do
      assert amounts(where(Organization, [o], amount_in(o.payroll, 100..200//1))) == [100, 200]
    end
  end

  describe "aggregates" do
    test "avg returns the mean as a money value" do
      [average] =
        Organization
        |> group_by([o], [currency_code(o.payroll)])
        |> select([o], avg(o.payroll))
        |> Repo.all()

      assert average.currency == :USD
      assert Decimal.equal?(Decimal.round(average.amount), Decimal.new(200))
    end

    test "sum without casting returns the raw composite" do
      [total] =
        Organization
        |> group_by([o], [currency_code(o.payroll)])
        |> select([o], sum(o.payroll, false))
        |> Repo.all()

      assert {"USD", amount} = total
      assert Decimal.equal?(amount, Decimal.new(600))
    end
  end

  describe "cast_decimal/1" do
    test "passes a decimal through unchanged" do
      decimal = Decimal.new("1.5")
      assert Money.Ecto.Query.API.Composite.cast_decimal(decimal) == decimal
    end
  end
end
