defmodule Test.Cldr do
  use Cldr,
    default_locale: "en",
    locales: ["en", "und", "de"],
    providers: [Cldr.Number]
end
