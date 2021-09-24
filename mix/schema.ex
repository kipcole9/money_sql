defmodule Organization do
  use Ecto.Schema

  @primary_key false
  schema "organizations" do
    field :payroll,         Money.Ecto.Composite.Type
    field :tax,             Money.Ecto.Composite.Type, fractional_digits: 4
    field :value,           Money.Ecto.Composite.Type, default: Money.new(:USD, 0)
    field :name,            :string
    field :employee_count,  :integer
    timestamps()
  end
end
