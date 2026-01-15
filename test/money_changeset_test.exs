defmodule Money.Changeset.Test do
  use ExUnit.Case
  import Money.Validate
  import Money.ValidationSupport

  test "Changeset default currency" do
    changeset = Organization.changeset(%Organization{}, %{payroll: "0"})
    assert changeset.changes.payroll == Money.new(:JPY, 0)
  end

  test "Changeset default currency in embedded schema" do
    changeset = Organization.changeset(%Organization{}, %{customers: [%{revenue: "12345.67"}]})
    assert hd(changeset.changes.customers).changes.revenue == Money.new(:USD, "12345.67")
  end

  test "money positive validation" do
    assert validate_money(test_changeset(), :value, less_than: Money.new(:USD, 200)).valid?

    assert validate_money(test_changeset(), :value, less_than_or_equal_to: Money.new(:USD, 200)).valid?

    assert validate_money(test_changeset(), :value, less_than_or_equal_to: Money.new(:USD, 100)).valid?

    assert validate_money(test_changeset(), :value, greater_than: Money.new(:USD, 50)).valid?

    assert validate_money(test_changeset(), :value, greater_than_or_equal_to: Money.new(:USD, 50)).valid?

    assert validate_money(test_changeset(), :value,
             greater_than_or_equal_to: Money.new(:USD, 100)
           ).valid?

    assert validate_money(test_changeset(), :value, equal_to: Money.new(:USD, 100)).valid?

    assert validate_money(test_changeset(), :value,
             greater_than: Money.new(:USD, 50),
             less_than: Money.new(:USD, 200)
           ).valid?
  end

  test "money negative validation" do
    refute validate_money(test_changeset(), :value, less_than: Money.new(:AUD, 200)).valid?

    assert validate_money(test_changeset(), :value, less_than: Money.new(:USD, 50)).errors ==
             [
               value:
                 {"must be less than %{money}",
                  [validation: :money, kind: :less_than, money: Money.new(:USD, 50)]}
             ]
  end

  test "Non-money changeset and comparison values" do
    assert validate_money(test_changeset(), :value, less_than: Money.new(:AUD, 200)).errors ==
             [
               value:
                 {"Cannot compare monies with different currencies. Received :USD and :AUD.",
                  [validation: :money, kind: :less_than, money: Money.new(:AUD, 200)]}
             ]

    assert_raise ArgumentError, ~r/expected target_value to be of type Money/, fn ->
      validate_money(test_changeset(), :value, less_than: 200)
    end

    assert_raise ArgumentError, ~r/expected value to be of type Money/, fn ->
      validate_money(non_money_changeset(), :employee_count, less_than: Money.new(:USD, 200))
    end

    assert_raise ArgumentError, ~r/expected value and target_value to be of type Money/, fn ->
      validate_money(non_money_changeset(), :employee_count, less_than: 200)
    end
  end
end
