Mix.install([{:elixir_input_curler, path: "../elixir_input_curler"}])

defmodule Day06Elixir do
  def part_one(data) do
    data
    |> String.split("\n")
    |> Enum.reduce([], fn line, builder ->
      line
      |> String.trim()
      |> String.split(~r"\s+")
      |> Enum.with_index()
      |> Enum.reduce(builder, fn {part, ix}, sub_builder ->
        case part do
          "+" ->
            List.update_at(sub_builder, ix, fn opands ->
              Enum.sum(opands)
            end)

          "*" ->
            List.update_at(sub_builder, ix, fn opands ->
              Enum.product(opands)
            end)

          _ ->
            if length(sub_builder) > ix do
              List.update_at(sub_builder, ix, fn opands ->
                [String.to_integer(part) | opands]
              end)
            else
              sub_builder ++ [[String.to_integer(part)]]
            end
        end
      end)
    end)
    |> Enum.sum()
  end

  def part_two(data) do
    line_len = data |> String.codepoints() |> Enum.find_index(&(&1 == "\n"))
    lines = data |> String.split("\n") |> Enum.map(&String.codepoints/1)
    num_lines = length(lines)

    0..(line_len - 1)
    |> Enum.reduce([[]], fn x, builder ->
      column =
        lines
        |> Enum.take(num_lines - 1)
        |> Enum.map(&Enum.at(&1, x))
        |> Enum.join()
        |> String.trim()

      if column == "" do
        [[] | builder]
      else
        List.update_at(builder, 0, &[String.to_integer(column) | &1])
      end
    end)
    |> Enum.zip(List.last(lines) |> Enum.reject(&(&1 == " ")) |> Enum.reverse())
    |> Enum.map(fn {opands, operator} ->
      case operator do
        "+" -> Enum.sum(opands)
        "*" -> Enum.product(opands)
      end
    end)
    |> Enum.sum()
  end
end

sample =
  "123 328  51 64 \n 45 64  387 23 \n  6 98  215 314\n*   +   *   +  "

data = ElixirInputCurler.input_for(6)

IO.puts("Sample one: #{Day06Elixir.part_one(sample)}")
IO.puts("Answer one: #{Day06Elixir.part_one(data)}")
IO.puts("Sample two: #{Day06Elixir.part_two(sample)}")
IO.puts("Answer two: #{Day06Elixir.part_two(data)}")
