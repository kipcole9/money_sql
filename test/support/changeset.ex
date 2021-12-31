defmodule Money.ValidationSupport do
  import Ecto.Changeset

  def test_changeset do
    params = %{"value" => "100"}

    changeset =
      %Organization{}
      |> cast(params, [:value])
  end

  def non_money_changeset do
    params = %{"employee_count" => "100"}

    changeset =
      %Organization{}
      |> cast(params, [:employee_count])
  end
end