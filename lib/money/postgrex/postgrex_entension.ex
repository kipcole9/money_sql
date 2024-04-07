defmodule Money.Postgrex.Extension do
  @moduledoc false
  import Postgrex.BinaryUtils, warn: false
  @behaviour Postgrex.SuperExtension

  def init(_), do: nil

  def matching(_),
    do: [type: "money_with_currency"]

  def format(_),
    do: :super_binary

  def oids(%Postgrex.TypeInfo{comp_elems: []}, _),
    do: nil

  def oids(%Postgrex.TypeInfo{comp_elems: comp_oids}, _),
    do: comp_oids

  def encode(_) do
    quote location: :keep do
      %Money{} = money, oids, types ->
        tuple = {to_string(money.currency), money.amount}
        data = encode_tuple(tuple, oids, types)
        [<<IO.iodata_length(data) + 4::int32(), tuple_size(tuple)::int32()>> | data]

      {_currency, _amount} = tuple, oids, types ->
        data = encode_tuple(tuple, oids, types)
        [<<IO.iodata_length(data) + 4::int32(), tuple_size(tuple)::int32()>> | data]

      other, _, _ ->
        raise DBConnection.EncodeError, Postgrex.Utils.encode_msg(other, "a Money.t or a tuple")
    end
  end

  def decode(_) do
    quote location: :keep do
      <<len::int32(), binary::binary-size(len)>>, nil, types ->
        <<count::int32(), data::binary>> = binary
        # decode_tuple/3 defined by TypeModule
        {currency, amount} = decode_tuple(data, count, types)
        Money.new(currency, amount)

      <<len::int32(), binary::binary-size(len)>>, oids, types ->
        <<_::int32(), data::binary>> = binary
        # decode_tuple/3 defined by TypeModule
        {currency, amount} = decode_tuple(data, oids, types)
        Money.new(currency, amount)
    end
  end
end