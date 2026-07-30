# Credo configuration for Money.Sql.
#
# Mirrors the Localize policy: strict, with `Design.AliasUsage` disabled.
# Money code fully qualifies many calls because module names read more
# clearly at the call site than an alias, and because trailing segments
# such as `List` and `String` shadow the standard library when aliased.
# Alias submodules opportunistically where the trailing segment does not
# clash, never as a bulk conversion.
%{
  configs: [
    %{
      name: "default",
      strict: true,
      files: %{
        included: ["lib/", "test/"]
      },
      checks: %{
        disabled: [
          {Credo.Check.Design.AliasUsage, []}
        ]
      }
    }
  ]
}
