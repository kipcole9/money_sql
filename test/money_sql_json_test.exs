defmodule Money.SQL.JSONTest do
  use ExUnit.Case, async: true

  doctest Money.SQL.JSON

  describe "the postgrex json_library contract" do
    test "exposes the two functions postgrex calls" do
      assert function_exported?(Money.SQL.JSON, :encode_to_iodata!, 1)
      assert function_exported?(Money.SQL.JSON, :decode!, 1)
    end

    test "a money map round trips as postgrex stores it" do
      {:ok, dumped} = Money.Ecto.Map.Type.dump(Money.new(:USD, 100), nil, [])

      decoded =
        dumped
        |> Money.SQL.JSON.encode_to_iodata!()
        |> Money.SQL.JSON.decode!()

      assert decoded == %{"currency" => "USD", "amount" => "100"}
    end

    test "decodes iodata as well as a binary" do
      assert Money.SQL.JSON.decode!([~s({"a":), ~s(1})]) == %{"a" => 1}
    end

    test "encoding returns iodata rather than a binary" do
      assert Money.SQL.JSON.encode_to_iodata!(%{"a" => 1}) |> :erlang.iolist_to_binary() ==
               ~s({"a":1})
    end
  end
end
