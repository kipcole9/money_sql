defmodule Money.Repo.Migrations.CreateMoneyTable do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name,            :string
      add :employee_count,  :integer
      add :payroll,         :money_with_currency
    end
  end
end
