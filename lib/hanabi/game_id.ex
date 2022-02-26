defmodule Hanabi.GameId do

  @spec generate_id :: String.t()
  def generate_id() do
    UUID.uuid4()
    |> String.slice(0..5)
    |> String.upcase()
    |> String.split_at(3)
    |> Tuple.to_list()
    |> Enum.join("-")
  end
end
