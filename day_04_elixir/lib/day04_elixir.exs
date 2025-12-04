Mix.install([{:elixir_input_curler, path: "../elixir_input_curler"}])

defmodule Day04Elixir do
  def part_one(diagram) do
    rolls = parse(diagram)

    Enum.count(rolls, fn {x, y} ->
      Enum.count(neighbours(x, y), fn neighbour ->
        MapSet.member?(rolls, neighbour)
      end) < 4
    end)
  end

  def part_two(diagram) do
    rolls = parse(diagram)
    removable_rolls(rolls)
  end

  defp parse(diagram) do
    diagram
    |> String.split()
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {line, y}, roll_set ->
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.reduce(roll_set, fn {location, x}, sub_roll_set ->
        if location == "@" do
          MapSet.put(sub_roll_set, {x, y})
        else
          sub_roll_set
        end
      end)
    end)
  end

  defp removable_rolls(rolls) do
    removable =
      Enum.filter(rolls, fn {x, y} ->
        Enum.count(neighbours(x, y), fn neighbour ->
          MapSet.member?(rolls, neighbour)
        end) < 4
      end)

    if Enum.empty?(removable) do
      0
    else
      Enum.count(removable) + removable_rolls(MapSet.reject(rolls, &Enum.member?(removable, &1)))
    end
  end

  defp neighbours(x, y) do
    [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
  end
end

sample = "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."

data = ElixirInputCurler.input_for(4)

IO.puts("Sample one: #{Day04Elixir.part_one(sample)}")
IO.puts("Answer one: #{Day04Elixir.part_one(data)}")
IO.puts("Sample two: #{Day04Elixir.part_two(sample)}")
IO.puts("Answer two: #{Day04Elixir.part_two(data)}")
