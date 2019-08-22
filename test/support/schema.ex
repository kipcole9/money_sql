defmodule Ledger do
  use Ecto.Schema

  @primary_key false
  schema "organizations" do
    field :payroll, Money.Ecto.Composite.Type
    field :name,            :string
    field :employee_count,  :integer
    timestamps()
  end
end