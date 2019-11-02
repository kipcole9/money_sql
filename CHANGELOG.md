# Changelog for Money_SQL v1.2.1

This is the changelog for Money_SQL v1.2.1 released on November 2nd, 2019.

### Bug Fixes

* Fixes `Money.Ecto.Composite.Type` and `Money.Ecto.Map.Type` by ensuring the `load/1` and `cast/1` callbacks conform to their typespecs.  Thanks to @bgracie. Closes #4 and #5.

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
