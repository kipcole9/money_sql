defmodule Money.DB.Test do
  use Money.SQL.RepoCase

  test "insert a record with a money amount" do
    m = Money.new(:USD, 100)
    assert {:ok, struct} = Repo.insert(%Organization{payroll: m})
    assert Money.cmp(m, struct.payroll) == :eq
  end

  test "select aggregate function sum on a :money_with_currency type" do
    m = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    sum = select(Organization, [o], type(sum(o.payroll), o.payroll)) |> Repo.one
    assert Money.cmp(sum, Money.new(:USD, 300))
  end

  test "Repo.aggregate function sum on a :money_with_currency type" do
    m = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    sum = Repo.aggregate(Organization, :sum, :payroll)
    assert Money.cmp(sum, Money.new(:USD, 300))
  end

end