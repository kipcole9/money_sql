defmodule Money.Changeset.Test do
  use ExUnit.Case

  test "Changeset default currency" do
    changeset = Organization.changeset(%Organization{}, %{payroll: "0"})
    assert changeset.changes.payroll == Money.new(:JPY, 0)
  end


end