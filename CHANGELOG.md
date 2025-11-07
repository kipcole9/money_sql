# Changelog

**Note** That `money_sql` is supported on Elixir 1.11 and later only.

## Money_SQL v1.11.1

This is the changelog for Money_SQL v1.11.1 released on November 8th, 2025.

### Bug Fixes

* Allow casting of (very old) type values from the database for `Money.Ecto.Map.Type`. Thanks to @peaceful-james for the PR. Closes #43.

## Money_SQL v1.11.0

This is the changelog for Money_SQL v1.11.0 released on January 24th, 2024.

### Enhancements

* When dumping a `Money.Ecto.Composite.Type`, detect if `dump/3` is being called by `Ecto.Type.embedded_dump/2`. If it is, then return a map that can be serialized to JSON. If it isn't (most cases) then return the tuple to be serialized to Postgres.  See [papertrail issue](https://github.com/izelnakri/paper_trail/issues/230).

## Money_SQL v1.10.2

This is the changelog for Money_SQL v1.10.2 released on December 13th, 2023.

### Bug Fixes

* Don't propagate some Ecto schema fields in `Money.Ecto.Composite.Type.init/2`. This change deletes additional `Ecto.Schema.field/3` options so they don't get loaded as format_options. Thanks to @axelclark for the PR. Closes #40.

* Fix Changelog headings and whitespace. Thanks to @c4710n for the PR. Closes #39.

## Money_SQL v1.10.1

This is the changelog for Money_SQL v1.10.1 released on November 3rd, 2023.

### Bug Fixes

* Fix compilation warnings on Elixir 1.16.

* Fix migration generator for `money_with_currency` type. Thanks to @bigardone for the issue and PR. Closes #37, closes #38.

## Money_SQL v1.10.0

This is the changelog for Money_SQL v1.10.0 released on October 30th, 2023.

### Bug Fixes

* The mix tasks that generate database function migrations (`money.gen.postgres.sum_function`, `money.gen.postgres.plus_operator` and `money.gen.postgres.min_max_functions`) need to be aware of the type of the `money_with_currency` "currency_code" element in a Postgres database. In releases of `ex_money_sql` up to 1.7.1 the type was `char(3)`. In later releases is changed to the more canonical `varchar`.  In turn, the database functions need to know the type for the internal accumulator. It is possible, as illustrated in issue #36, to have generated the `money_with_currency` "currency_code" type as `char(3)` and then move to a later release of `ex_money_sql`. In which case the money database function migrations would fail because they were built with `varchar` accumulators.  This release will detect the underlying type of the `money_with_currency` "currency_code" element and adjust the migration accordingly. Thanks to @bigardone for the report and motivation to get this done. Closes #36.

### Enhancements

* Adds database functions for unary negation and the operation `-`. Thanks to @zachdaniel for the PR.

## Money_SQL v1.9.3

This is the changelog for Money_SQL v1.9.2 released on October 1st, 2023.

### Bug Fixes

* Return an error if loading invalid amounts such as `Inf` and `NaN`. Thanks to @dhedlund for the report and PR. Closes #34.

## Money_SQL v1.9.2

This is the changelog for Money_SQL v1.9.2 released on June 17th, 2022.

### Embedded Schema Configuration

Please ensure that if you are using Ecto [embedded schemas](https://hexdocs.pm/ecto/embedded-schemas.html) that include a `money` type that it is configured with the type `Money.Ecto.Map.Type`, **NOT** `Money.Ecto.Composite.Type`.

In previous releases the misconfiguration of the type worked by accident. In this release and subsequent releases you will likely see an exception like `** (Protocol.UndefinedError) protocol Jason.Encoder not implemented for {"USD", Decimal.new("50.00")} of type Tuple`. This is most likely an indication of type misconfiguration in an embedded schema.

### Bug Fixes

* Fixes dumping and loading of `Money.Ecto.Map.Type` when used in embedded schemas. Many thanks to @redrabbit for the issue and the PR.  Closes #32.

## Money_SQL v1.9.1

This is the changelog for Money_SQL v1.9.1 released on May 12th, 2022.

### Bug Fixes

* Fixes casting a map when the `"amount"` is `nil`. Thanks to @treere for the report and PR. Closes #30.

## Money_SQL v1.9.0

This is the changelog for Money_SQL v1.9.0 released on April 28th, 2022.

### Enhancements

* Adds `Money.Ecto.Query.API` query helpers to simplify Ecto queries involving money columns. Thanks very much to @am-kantox for the excellent suggestion and PR.

## Money_SQL v1.8.0

This is the changelog for Money_SQL v1.8.0 released on December 26th, 2022.

### Enhancements

* Adds migrations and SQL functions to support `min` and `max` aggregate functions for Postgres when using the `money_with_currency` composite data type.  The new mix task is `money.gen.postgres.min_max_functions`.

* Renames the migration task `money.gen.postgres.aggregate_functions` to `money.gen.postgres.sum_function` to better reflect its intent. This change affects only new installations. It has no effect on pre-existing generated migrations.

## Money_SQL v1.7.3

This is the changelog for Money_SQL v1.7.3 released on December 18th, 2022.

### Bug Fixes

* When loading money from the database with the `Money.Ecto.Map.Type` type, do not do localized parsing of the amount. The amount is always saved using `Decimal.to_string/1` and therefore is not localized. It must not be parsed with localization on loading.

## Money_SQL v1.7.2

This is the changelog for Money_SQL v1.7.2 released on August 27th, 2022.

### Change in data type

* The "amount" component of `money_with_currency` in a Postgres database is now `varchar` instead of `char(3)`. This is both more canonical in a Postgres database and allows for the use of Digial Tokens (crypto currencies) which have a code greater than 3 characters long.

### Bug Fixes

* Makes the aggregate functions parallel-safe which provides up to 100% speed improvement. Thanks to @milangupta1 for the PR.

## Money_SQL v1.7.1

This is the changelog for Money_SQL v1.7.1 released on July 8th, 2022.

### Bug Fixes

* Fixes casting a money map when the currency is `nil`. Thanks to @frahugo for the report. Closes #24.

## Money_SQL v1.7.0

This is the changelog for Money_SQL v1.7.0 released on May 21st, 2022.

### Enhancements

* Adds the module `Money.Validation` to provide [Ecto Changeset validations](https://hexdocs.pm/ecto/Ecto.Changeset.html#module-validations-and-constraints). In particular it adds `Money.Validation.validate_money/3` which behaves exactly like `Ecto.Changeset.validate_number/3` only for `t:Money.t/0` types.

## Money_SQL v1.6.0

This is the changelog for Money_SQL v1.6.0 released on December 31st, 2021.

**Note** That `money_sql` is now supported on Elixir 1.10 and later only.

### Enhancements

* `t:Money.Ecto.Composite.Type` and `t:Money.Ecto.Map.Type` now return the exception module when there is an error in `cast/1`. For example:

```elixir
iex> Money.Ecto.Composite.Type.cast("") ==
{:error,
 [
   exception: Money.InvalidAmountError,
   message: "Amount cannot be converted to a number: \"\""
 ]}
 ```
 The expected exceptions are:

   * `Money.InvalidAmountError`
   * `Money.UnknownCurrencyError`
   * `Money.ParseError`

Thanks to @DaTrader for the enhancement request.

## Money_SQL v1.5.2

This is the changelog for Money_SQL v1.5.2 released on December 13th, 2021.

**Note** That `money_sql` is now supported on Elixir 1.10 and later only.

### Bug Fixes

* Fixes `c:Ecto.ParameterizedType.embed_as/2` callback for the `Ecto.ParameterizedType` behaviour. Thanks to @nseantanly for the report and the PR.

## Money_SQL v1.5.1

This is the changelog for Money_SQL v1.5.1 released on December 8th, 2021.

**Note** That `money_sql` is now supported on Elixir 1.10 and later only.

### Bug Fixes

* Implements `c:Ecto.ParameterizedType.equal?/3` callback for the `Ecto.ParameterizedType` behaviour. Thanks to @namhoangyojee for the report and the PR.

* Adds `@impl Ecto.ParamaterizedType` to the relevant callbacks.

## Money_SQL v1.5.0

This is the changelog for Money_SQL v1.5.0 released on September 25th, 2021.

#### Enhancements

* Adds a `+` operator for the Postgres type `:money_with_currency`

* The name of the migration to create the `:money_with_currency` type has shortened to be `money.gen.postgres.money_with_currency`

## Money_SQL v1.4.5

This is the changelog for Money_SQL v1.4.5 released on June 3rd, 2021.

#### Bug Fixes

* Remove conditional compilation in `Money.Ecto.Composite.Type` - the type is always `Ecto.ParameterizedType`.

## Money_SQL v1.4.4

This is the changelog for Money_SQL v1.4.4 released on March 18th, 2021.

#### Bug Fixes

* Don't use `is_struct/1` guard to support compatibility on older Elixir releases

## Money_SQL v1.4.3

This is the changelog for Money_SQL v1.4.3 released on February 17th, 2021.

#### Bug Fixes

* Don't propogate a `:default` option into the `t:Money` from the schema. Fixes #14. Thanks to @emaiax.

## Money_SQL v1.4.2

This is the changelog for Money_SQL v1.4.2 released on February 12th, 2021.

#### Bug Fixes

* Dumping/loading `nil` returns `{:ok, nil}`.  Thanks to @morinap.

## Money_SQL v1.4.1

This is the changelog for Money_SQL v1.4.1 released on February 11th, 2021.

#### Bug Fixes

* Casting `nil` returns `{:ok, nil}`.  Thanks to @morinap.

## Money_SQL v1.4.0

This is the changelog for Money_SQL v1.4.0 released on February 10th, 2021.

#### Bug Fixes

* Fix parsing error handling in `Money.Ecto.Composite.Type.cast/2`. Thanks to @NikitaAvvakumov. Closes #10.

* Fix casting localized amounts. Thanks to @olivermt. Closes #11.

#### Enhancements

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

## Money_SQL v1.3.1

This is the changelog for Money_SQL v1.3.1 released on September 30th, 2020.

#### Bug Fixes

* Fixes compatibility with both `Decimal` version `1.x` and `2.x`. Thanks to @doughsay and @coladarci for the report. Closes #8.

## Money_SQL v1.3.0

This is the changelog for Money_SQL v1.3.0 released on January 30th, 2020.

#### Enhancements

* Updates to `ex_money` version `5.0`. Thanks to @morgz

## Money_SQL v1.2.1

This is the changelog for Money_SQL v1.2.1 released on November 3rd, 2019.

#### Bug Fixes

* Fixes `Money.Ecto.Composite.Type` and `Money.Ecto.Map.Type` by ensuring the `load/1` and `cast/1` callbacks conform to their typespecs.  Thanks to @bgracie. Closes #4 and #5.

* Fixes the migration templates for `money.gen.postgres.aggregate_functions` to use `numeric` intermediate types rather than `numeric(20,8)`. For current installations it should be enough to run `mix money.gen.postgres.aggregate_functions` again followed by `mix ecto.migrate` to install the corrected aggregate function.

## Money_SQL v1.2.0

This is the changelog for Money_SQL v1.2.0 released on November 2nd, 2019.

#### Bug Fixes

* Removes the precision specification from intermediate results of the `sum` aggregate function for Postgres.

#### Enhancements

* Adds `equal?/2` callbacks to the `Money.Ecto.Composite.Type` and `Money.Ecto.Map.Type` for `ecto_sql` version 3.2

## Money_SQL v1.1.0

This is the changelog for Money_SQL v1.1.0 released on August 22nd, 2019.

#### Enhancements

* Renames the migration that generator that creates the Postgres composite type to be more meaningful.

#### Bug Fixes

* Correctly generate and execute migrations.  Fixes #1 and #2.  Thanks to @davidsulc, @KungPaoChicken.

## Money_SQL v1.0.0

This is the changelog for Money_SQL v1.0.0 released on July 8th, 2019.

#### Enhancements

* Initial release.  Extracted from [ex_money](https://hex.pm/packages/ex_money)
