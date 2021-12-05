ExUnit.start()
{:ok, _pid} = Money.SQL.Repo.start_link()
:ok = Ecto.Adapters.SQL.Sandbox.mode(Money.SQL.Repo, :manual)

defmodule Money.SQL.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Money.SQL.Repo

      import Ecto
      import Ecto.Query
      import Money.SQL.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Money.SQL.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Money.SQL.Repo, {:shared, self()})
    end

    :ok
  end
end
