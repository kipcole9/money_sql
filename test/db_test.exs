defmodule Money.DB.Test do
  use Money.SQL.RepoCase

  test "insert a record with a money amount" do
    m = Money.new(:USD, 100)
    assert {:ok, struct} = Repo.insert(%Organization{payroll: m})
    assert Money.compare(m, struct.payroll) == :eq
  end

  test "insert a record with a money amount with params" do
    m = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{name: "a", tax: m})
    struct = Repo.get_by(Organization, name: "a")

    assert Money.compare(m, struct.tax) == :eq
    assert struct.tax.format_options == [fractional_digits: 4]
  end

  test "insert a record with a default money amount without params" do
    m = Money.new(:USD, 0)
    {:ok, _} = Repo.insert(%Organization{name: "a"})
    struct = Repo.get_by(Organization, name: "a")

    assert struct.value == m
    assert Money.compare(m, struct.value) == :eq
    assert struct.value.format_options == []
  end

  test "select aggregate function sum on a :money_with_currency type" do
    m = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    sum = select(Organization, [o], type(sum(o.payroll), o.payroll)) |> Repo.one
    assert Money.compare(sum, Money.new(:USD, 300)) == :eq
  end

  test "Repo.aggregate function sum on a :money_with_currency type" do
    m = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    sum = Repo.aggregate(Organization, :sum, :payroll)
    assert Money.compare(sum, Money.new(:USD, 300)) == :eq
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

  test "aggregate from a keyword query using a schema module" do
    m = Money.new(:USD, 100)
    m2 = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m2})

    query =
      from(
        organization in Organization,
        select: %{
          total: type(sum(organization.payroll), organization.payroll)
        }
      )

    assert Repo.all(query) == [%{total: Money.new(:USD, 300)}]
  end

  test "keyword query using a schema module casting with a type" do
    m = Money.new(:USD, 100)
    m2 = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m2})

    query =
      from(
        organization in Organization,
        select: %{
          total: type(sum(organization.payroll), ^Money.Ecto.Composite.Type.cast_type())
        }
      )

    assert Repo.all(query) == [%{total: Money.new(:USD, 300)}]
  end

  test "aggregate from a keyword query using a schemaLESS query" do
    m = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})

    query =
      from(
        organization in "organizations",
        select: %{
          total: type(sum(organization.payroll),
            ^Money.Ecto.Composite.Type.cast_type()
          )
        }
      )

    assert Repo.all(query) == [%{total: Money.new(:USD, 300)}]
  end

  test "select using Ecto functional query composition" do
    m = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m})

    query =
      from(Organization)
      |> select([o], %{money: o.payroll})

    assert [%{money: ^m}] = Repo.all(query)
  end

  test "select distinct aggregate function sum on a :money_with_currency type" do
    m = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: Money.new(:USD, 200)})

    query = select(Organization, [o], type(fragment("SUM(DISTINCT ?)", o.payroll), o.payroll))
    sum = query |> Repo.one
    assert Money.compare(sum, Money.new(:USD, 300)) == :eq
  end

  test "filter on a currency type" do
    m = Money.new(:USD, 100)
    m2 = Money.new(:AUD, 200)

    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m2})
    {:ok, _} = Repo.insert(%Organization{payroll: m})
    {:ok, _} = Repo.insert(%Organization{payroll: m2})

    query = from o in Organization,
              where: fragment("currency_code(payroll)") == "USD",
              select: sum(o.payroll)

    result = query |> Repo.one

    assert result == Money.new(:USD, 200)
  end

  test "nil values for money is ok" do
    assert {:ok, _} = Repo.insert(%Organization{name: "a", payroll: nil})
    organization = Repo.get_by(Organization, name: "a")
    assert is_nil(organization.payroll)
  end

  test "Plus operator a :money_with_currency type" do
    m = Money.new(:USD, 100)
    {:ok, _} = Repo.insert(%Organization{payroll: m, tax: m})

    query =
      from o in Organization,
        select: type(fragment("payroll + tax"), o.payroll)

    assert Repo.one(query) == Money.new(:USD, 200)
  end

  test "Plus operator with incompatible money currencies" do
    m = Money.new(:USD, 100)
    n = Money.new(:AUD, 100)

    {:ok, _} = Repo.insert(%Organization{payroll: m, tax: n})

    query =
      from o in Organization,
        select: type(fragment("payroll + tax"), o.payroll)

    assert_raise Postgrex.Error, fn ->
      Repo.one(query)
    end
  end

end
