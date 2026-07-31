defmodule Money.SQL.JSON do
  @moduledoc """
  A Postgrex `:json_library` adapter over the Erlang `:json` module.

  `Money.Ecto.Map.Type` stores a money amount in a `jsonb` column, so
  Postgrex needs a JSON library to encode and decode it. Postgrex calls
  `encode_to_iodata!/1` and `decode!/1`, which the Erlang `:json` module
  does not provide under those names; this module supplies them.

  Configure it in your application:

      config :postgrex, :json_library, Money.SQL.JSON

  `:json` is built into OTP 27 and later. On OTP 26 add
  [json_polyfill](https://hex.pm/packages/json_polyfill), which provides
  it:

      {:json_polyfill, "~> 0.2 or ~> 1.0"}

  Postgrex reads this setting at compile time, so after changing it run
  `mix deps.compile postgrex --force` once.

  Any module exposing `encode_to_iodata!/1` and `decode!/1` works here —
  Elixir 1.18's built-in `JSON` module does, as does `Jason`. This module
  exists so that the same configuration works on every Elixir and OTP
  version this library supports.

  """

  @typedoc """
  A term that can be encoded as JSON, as defined by the Erlang `:json`
  module.
  """
  @type encodable :: :json.encode_value()

  @typedoc """
  A term decoded from JSON, as defined by the Erlang `:json` module.
  """
  @type decoded :: :json.decode_value()

  @doc """
  Encodes a term as JSON iodata.

  ### Arguments

  * `term` is any term the Erlang `:json` module can encode.

  ### Returns

  * The encoded JSON as iodata.

  ### Examples

      iex> Money.SQL.JSON.encode_to_iodata!(%{"currency" => "USD"}) |> IO.iodata_to_binary()
      "{\\"currency\\":\\"USD\\"}"

  """
  @spec encode_to_iodata!(encodable()) :: iodata()
  def encode_to_iodata!(term) do
    :json.encode(term)
  end

  @doc """
  Decodes JSON into a term.

  ### Arguments

  * `json` is a JSON string or iodata.

  ### Returns

  * The decoded term.

  ### Examples

      iex> Money.SQL.JSON.decode!(~s({"currency":"USD"}))
      %{"currency" => "USD"}

  """
  @spec decode!(iodata()) :: decoded()
  def decode!(json) do
    :json.decode(IO.iodata_to_binary(json))
  end
end
