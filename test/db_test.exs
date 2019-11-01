defmodule Money.DB.Test do
  use Money.SQL.RepoCase

  test "insert a record with a money amount" do
    m = Money.new(:USD, 100)
    assert {:ok, struct} = Repo.insert(%Organization{payroll: m})
    assert Money.cmp(m, struct.payroll) == :eq
  end

end