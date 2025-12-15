Mix.install([{:elixir_input_curler, path: "../elixir_input_curler"}])

defmodule Day10Elixir do
  def part_one(data) do
    parse(data)
    |> Enum.map(fn %{lights: lights, toggles: toggles} ->
      num_toggles = length(toggles)

      start = List.duplicate(false, length(lights))

      0..(2 ** num_toggles - 1)
      |> Enum.map(fn presses ->
        presses
        |> Integer.to_string(2)
        |> String.pad_leading(num_toggles, "0")
        |> String.codepoints()
      end)
      |> Enum.filter(fn presses ->
        presses
        |> Enum.with_index()
        |> Enum.filter(fn {yn, _} -> yn == "1" end)
        |> Enum.reduce(start, fn {_, ix}, acc ->
          toggles
          |> Enum.at(ix)
          |> Enum.reduce(acc, fn flip, sub_acc ->
            List.update_at(sub_acc, flip, &(!&1))
          end)
        end) ==
          lights
      end)
      |> Enum.map(fn presses ->
        presses |> Enum.filter(&(&1 == "1")) |> Enum.count()
      end)
      |> Enum.min()
    end)
    |> Enum.sum()
  end

  def part_two(data) do
    parse(data)
    |> Enum.map(fn %{toggles: toggles, joltages: joltages} ->
      num_toggles = length(toggles)
      num_jolts = length(joltages)

      # Build dictionary of what pressing each combination of buttons (once) gets you, hashed by parity
      pattern_dictionary =
        0..(2 ** num_toggles - 1)
        |> Enum.reduce(%{}, fn binary_presses, dict ->
          presses_as_chars =
            binary_presses
            |> Integer.to_string(2)
            |> String.pad_leading(num_toggles, "0")
            |> String.codepoints()

          num_presses = presses_as_chars |> Enum.count(&(&1 == "1"))

          result =
            presses_as_chars
            |> Enum.with_index()
            |> Enum.filter(fn {yn, _} -> yn == "1" end)
            |> Enum.reduce(List.duplicate(0, num_jolts), fn {_, ix}, jolts ->
              toggles
              |> Enum.at(ix)
              |> Enum.reduce(jolts, fn inc, jolts ->
                List.update_at(jolts, inc, &(&1 + 1))
              end)
            end)

          parity = Enum.map(result, &rem(&1, 2))

          dict = if Map.has_key?(dict, parity), do: dict, else: Map.put(dict, parity, %{})

          Map.update!(dict, parity, fn patterns ->
            Map.update(patterns, result, num_presses, fn old ->
              if old <= num_presses, do: old, else: num_presses
            end)
          end)
        end)

      min_presses_for(joltages, pattern_dictionary)
    end)
    |> Enum.sum()
  end

  defp min_presses_for(target, pattern_dictionary) do
    if Enum.all?(target, &(&1 == 0)) do
      0
    else
      target_parity = Enum.map(target, &rem(&1, 2))

      if !Map.has_key?(pattern_dictionary, target_parity) do
        10000
      else
        pattern_dictionary
        |> Map.get(target_parity)
        |> Enum.reduce(10000, fn {pattern, num_presses}, best ->
          if target |> Enum.zip(pattern) |> Enum.any?(fn {t, p} -> t < p end) do
            best
          else
            new_target = target |> Enum.zip(pattern) |> Enum.map(fn {t, p} -> div(t - p, 2) end)
            min(best, num_presses + min_presses_for(new_target, pattern_dictionary) * 2)
          end
        end)
      end
    end
  end

  defp parse(data) do
    data
    |> String.split("\n")
    |> Enum.map(fn line ->
      [lights | rest] = line |> String.split(" ")
      [joltages | rest] = rest |> Enum.reverse()

      lights =
        lights
        |> String.codepoints()
        |> Enum.reject(&(&1 == "[" || &1 == "]"))
        |> Enum.map(fn c ->
          case c do
            "." -> false
            "#" -> true
          end
        end)

      toggles =
        rest
        |> Enum.reverse()
        |> Enum.map(fn toggle ->
          Regex.scan(~r"\d+", toggle) |> Enum.map(fn [n] -> String.to_integer(n) end)
        end)

      joltages =
        joltages
        |> String.trim_leading("{")
        |> String.trim_trailing("}")
        |> String.split(",")
        |> Enum.map(&String.to_integer(&1))

      %{lights: lights, toggles: toggles, joltages: joltages}
    end)
  end
end

sample =
  "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}"

data = ElixirInputCurler.input_for(10)

IO.puts("Sample one: #{Day10Elixir.part_one(sample)}")
IO.puts("Answer one: #{Day10Elixir.part_one(data)}")
IO.puts("Sample two: #{Day10Elixir.part_two(sample)}")
IO.puts("Answer two: #{Day10Elixir.part_two(data)}")
