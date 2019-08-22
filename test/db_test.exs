defmodule Money.DB.Test do
  use Money.SQL.RepoCase

  test "selecting all" do
    Repo.all(Ledger)
  end
end