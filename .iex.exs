alias Ecto.Adapters.SQL
alias Money.SQL.Repo

import Money.Ecto.Query.API.Composite
import Money.Ecto.Query.API

import Ecto
import Ecto.Query

Repo.start_link()

Repo.delete_all Organization

[m_usd: Money.new(:USD, 100), m_aud: Money.new(:AUD, 50), m_eur: Money.new(:EUR, 100)]
|> tap(fn [m_usd: m_usd, m_aud: m_aud, m_eur: m_eur] ->
  {:ok, _} = Repo.insert(%Organization{revenue: m_eur, payroll: m_eur, name: "EU"})
  {:ok, _} = Repo.insert(%Organization{revenue: m_usd, payroll: m_usd, name: "UE"})
  {:ok, _} = Repo.insert(%Organization{revenue: m_usd, payroll: m_usd, name: "UE"})
  {:ok, _} = Repo.insert(%Organization{revenue: m_aud, payroll: m_aud, name: "EU"})
  {:ok, _} = Repo.insert(%Organization{revenue: m_aud, payroll: m_aud, name: "EU"})
  {:ok, _} = Repo.insert(%Organization{revenue: m_aud, payroll: m_aud, name: "AU"})
  {:ok, _} = Repo.insert(%Organization{revenue: nil, payroll: nil, name: "EU"})
end)
