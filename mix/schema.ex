defmodule Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "organizations" do
    field :payroll,         Money.Ecto.Composite.Type, default_currency: :JPY
    field :tax,             Money.Ecto.Composite.Type, fractional_digits: 4
    field :value,           Money.Ecto.Composite.Type, default: Money.new(:USD, 0)
    field :revenue,         Money.Ecto.Map.Type, default: Money.new(:AUD, 0)
    field :name,            :string
    field :employee_count,  :integer
    embeds_many :customers, Customer do
      field :name, :string
      field :revenue, Money.Ecto.Map.Type, default: Money.new(:USD, 0)
    end
    timestamps()
  end

  def changeset(organization, params \\ %{}) do
    organization
    |> cast(params, [:payroll])
    |> cast_embed(:customers, with: &customer_changeset/2)
  end

  def customer_changeset(customer, params \\ %{}) do
    cast(customer, params, [:name, :revenue])
  end
end
