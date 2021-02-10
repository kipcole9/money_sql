# Changelog for Money_SQL v1.4.0

This is the changelog for Money_SQL v1.4.0 released on ____, 2021.

### Enhancements

* Changes `Money.Ecto.Composite.Type` and `Money.Ecto.Map.Type` to be `ParameterizedType`. As a result, Ecto 3.5 or later is required. This change allows configuration of format options for the `:money_with_currency` to added as parameters in the Ecto schema.  For the example schema:
```elixir
defmodule Organization do
  use Ecto.Schema

  @primary_key false
  schema "organizations" do
    field :payroll,         Money.Ecto.Composite.Type
    field :tax,             Money.Ecto.Composite.Type, fractional_digits: 4
    field :name,            :string
    field :employee_count,  :integer
    timestamps()
  end
end
```
The field `:tax` will be instantiated as a `Money.t` with `:format_options` of `fractional_digits: 4`.

# Changelog for Money_SQL v1.3.1

This is the changelog for Money_SQL v1.3.1 released on September 30th, 2020.

### Bug Fixes

* Fixes compatibility with both `Decimal` version `1.x` and `2.x`. Thanks to @doughsay and @coladarci for the report. Closes #8.

# Changelog for Money_SQL v1.3.0

This is the changelog for Money_SQL v1.3.0 released on January 30th, 2020.

### Enhancements

* Updates to `ex_money` version `5.0`. Thanks to @morgz

# Changelog for Money_SQL v1.2.1

This is the changelog for Money_SQL v1.2.1 released on November 3rd, 2019.

### Bug Fixes

* Fixes `Money.Ecto.Composite.Type` and `Money.Ecto.Map.Type` by ensuring the `load/1` and `cast/1` callbacks conform to their typespecs.  Thanks to @bgracie. Closes #4 and #5.

* Fixes the migration templates for `money.gen.postgres.aggregate_functions` to use `numeric` intermediate types rather than `numeric(20,8)`. For current installations it should be enough to run `mix money.gen.postgres.aggregate_functions` again followed by `mix ecto.migrate` to install the corrected aggregate function.

# Changelog for Money_SQL v1.2.0

This is the changelog for Money_SQL v1.2.0 released on November 2nd, 2019.

### Bug Fixes

* Removes the precision specification from intermediate results of the `sum` aggregate function for Postgres.

### Enhancements

* Adds `equal?/2` callbacks to the `Money.Ecto.Composite.Type` and `Money.Ecto.Map.Type` for `ecto_sql` version 3.2

# Changelog for Money_SQL v1.1.0

This is the changelog for Money_SQL v1.1.0 released on August 22nd, 2019.

### Enhancements

* Renames the migration that generator that creates the Postgres composite type to be more meaningful.

### Bug Fixes

* Correctly generate and execute migrations.  Fixes #1 and #2.  Thanks to @davidsulc, @KungPaoChicken.

# Changelog for Money_SQL v1.0.0

This is the changelog for Money_SQL v1.0.0 released on July 8th, 2019.

### Enhancements

* Initial release.  Extracted from [ex_money](https://hex.pm/packages/ex_money)
