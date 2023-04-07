defmodule Money.Query.API.Test do
  use Money.SQL.RepoCase
  use Money.Ecto.Query.API, adapter: Money.Ecto.Query.API.Postgres

  describe "Query.API helpers" do
    setup do
      [m_usd: Money.new(:USD, 100), m_aud: Money.new(:AUD, 50), m_eur: Money.new(:EUR, 100)]
      |> tap(fn [m_usd: m_usd, m_aud: m_aud, m_eur: m_eur] ->
        {:ok, _} = Repo.insert(%Organization{payroll: m_eur, name: "EU"})
        {:ok, _} = Repo.insert(%Organization{payroll: m_usd, name: "UE"})
        {:ok, _} = Repo.insert(%Organization{payroll: m_usd, name: "UE"})
        {:ok, _} = Repo.insert(%Organization{payroll: m_aud, name: "EU"})
        {:ok, _} = Repo.insert(%Organization{payroll: m_aud, name: "EU"})
        {:ok, _} = Repo.insert(%Organization{payroll: m_aud, name: "AU"})
        {:ok, _} = Repo.insert(%Organization{payroll: nil, name: "EU"})
      end)
    end

    test "select by currency(-ies)", %{m_aud: m_aud, m_usd: m_usd, m_eur: m_eur} do
      same_currency =
        Organization
        |> where([o], currency_is(o.payroll, :AUD))
        |> select([o], o.payroll)
        |> Repo.all()

      assert [^m_aud, ^m_aud, ^m_aud] = same_currency

      two_currencies =
        from(o in Organization, where: currency_in(o.payroll, [:USD, :EUR]), select: o.payroll)
        |> Repo.all()

      assert [^m_eur, ^m_usd, ^m_usd] = Enum.sort(two_currencies)
    end

    test "sum by currencies", %{m_eur: m_eur} do
      eu_standard =
        Organization
        |> where([o], o.name == ^"EU")
        |> group_by([o], [currency_code(o.payroll)])
        |> select([o], sum(o.payroll, true))

      eu_helpers =
        Organization
        |> total_by([o], o.payroll)
        |> where([o], o.name == ^"EU")

      assert eu_standard.group_bys |> Enum.map(& &1.expr) ==
               eu_helpers.group_bys |> Enum.map(& &1.expr)

      eu = Repo.all(eu_helpers)
      auds_eurs = [Money.new(:AUD, 100), m_eur]
      assert ^auds_eurs = Enum.sort(eu)
    end

    test "sum by currency", %{m_aud: m_aud} do
      aud_eu_standard =
        Organization
        |> where([o], o.name == ^"EU" or o.name == ^"AU")
        |> group_by([o], [currency_code(o.payroll)])
        |> select([o], sum(o.payroll, true))

      aud_eu_helpers =
        Organization
        |> total_by([o], o.payroll, :AUD)
        |> where([o], o.name == ^"EU" or o.name == ^"AU")

      assert aud_eu_standard.group_bys |> Enum.map(& &1.expr) ==
               aud_eu_helpers.group_bys |> Enum.map(& &1.expr)

      aud_eu = Repo.one(aud_eu_helpers)
      {:ok, auds} = Money.sum([m_aud, m_aud, m_aud])
      assert ^auds = aud_eu
    end

    test "select by amount", %{m_usd: m_usd, m_eur: m_eur} do
      no_currency_filter =
        Organization
        |> where([o], amount_is(o.payroll, 100))
        |> select([o], o.payroll)
        |> Repo.all()

      assert [^m_eur, ^m_usd, ^m_usd] = no_currency_filter

      currency_filter =
        Organization
        |> where([o], currency_is(o.payroll, "USD"))
        |> where([o], amount_is(o.payroll, 100))
        |> select([o], o.payroll)
        |> Repo.all()

      assert [^m_usd, ^m_usd] = currency_filter

      currency_filter =
        Organization
        |> where([o], money_is(o.payroll, Money.new!(100, :USD)))
        |> select([o], o.payroll)
        |> Repo.all()

      assert [^m_usd, ^m_usd] = currency_filter
    end

    test "select by amounts", %{m_usd: m_usd, m_eur: m_eur} do
      no_currency_filter =
        Organization
        |> where([o], amount_in(o.payroll, 90..110))
        |> select([o], o.payroll)
        |> Repo.all()

      assert [^m_eur, ^m_usd, ^m_usd] = no_currency_filter

      currency_filter =
        Organization
        |> where([o], currency_is(o.payroll, "USD"))
        |> where([o], amount_in(o.payroll, 100..90//-1))
        |> select([o], o.payroll)
        |> Repo.all()

      assert [^m_usd, ^m_usd] = currency_filter
    end
  end
end
