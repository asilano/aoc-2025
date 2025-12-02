Mix.install([{:elixir_input_curler, path: "../elixir_input_curler"}])

defmodule Day02Elixir do
  require Integer

  def part_one(data) do
    data
    |> String.split(",")
    |> Enum.reduce(0, fn range, sum ->
      [start, stop] = String.split(range, "-")

      sum +
        (Range.new(String.to_integer(start), String.to_integer(stop))
         |> Enum.filter(fn num ->
           digits = num |> Integer.to_string() |> String.length()

           case digits do
             d when Integer.is_odd(d) ->
               false

             d when Integer.is_even(d) ->
               left = num |> div(10 ** div(d, 2))
               right = num |> rem(10 ** div(d, 2))
               left == right
           end
         end)
         |> Enum.sum())
    end)
  end

  def part_two(data) do
    data
    |> String.split(",")
    |> Enum.reduce(0, fn range, sum ->
      [start, stop] = String.split(range, "-")

      sum +
        (Range.new(String.to_integer(start), String.to_integer(stop))
         |> Enum.filter(fn num ->
           num_str = Integer.to_string(num)
           len = String.length(num_str)

           1..div(len, 2)//1
           |> Enum.any?(fn part_len ->
             case rem(len, part_len) do
               x when x != 0 ->
                 false

               0 ->
                 num_str
                 |> String.codepoints()
                 |> Enum.chunk_every(part_len)
                 |> Enum.uniq()
                 |> length() == 1
             end
           end)
         end)
         |> Enum.sum())
    end)
  end
end

sample =
  "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"

data = ElixirInputCurler.input_for(2)

IO.puts("Sample one: #{Day02Elixir.part_one(sample)}")
IO.puts("Answer one: #{Day02Elixir.part_one(data)}")
IO.puts("Sample two: #{Day02Elixir.part_two(sample)}")
IO.puts("Answer two: #{Day02Elixir.part_two(data)}")
