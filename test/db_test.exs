defmodule Money.DB.Test do
  use Money.SQL.RepoCase

  test "insert a record with a money amount" do
    m = Money.new(:USD, 100)
    Repo.insert(%Organization{payroll: m})
    assert {:ok, struct} = Repo.insert(%Organization{payroll: m})
    assert Money.compare(m, struct.payroll) == :eq
  end

  test "select aggregate function sum on a :money_with_currency type" do
    m = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    sum = select(Organization, [o], type(sum(o.payroll), o.payroll)) |> Repo.one
    assert Money.compare(sum, Money.new(:USD, 300))
  end

  test "Repo.aggregate function sum on a :money_with_currency type" do
    m = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    sum = Repo.aggregate(Organization, :sum, :payroll)
    assert Money.compare(sum, Money.new(:USD, 300))
  end

  test "Exception is raised if trying to sum different currencies" do
    m = Money.new(:USD, 100)
    m2 = Money.new(:AUD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m2})
    assert_raise Postgrex.Error, fn ->
      Repo.aggregate(Organization, :sum, :payroll)
    end
  end

  test "select distinct aggregate function sum on a :money_with_currency type" do
    m = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: Money.new(:USD, 200)})

    query = select(Organization, [o], type(fragment("SUM(DISTINCT ?)", o.payroll), o.payroll))
    sum = query |> Repo.one
    assert Money.compare(sum, Money.new(:USD, 300))
  end

end
