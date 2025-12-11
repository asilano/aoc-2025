Mix.install([{:elixir_input_curler, path: "../elixir_input_curler"}])

defmodule Simplex do
  def maximise(objective, constraints, num_variables) do
    constraints =
      constraints
      |> Enum.map(fn {coeffs, type, limit} ->
        case type do
          :at_most -> {coeffs, limit}
        end
      end)

    num_constraints = length(constraints)
    objective = [1 | objective ++ List.duplicate(0, num_constraints + 1)]

    constraints =
      constraints
      |> Enum.with_index()
      |> Enum.map(fn {{coeffs, limit}, ix} ->
        [
          0
          | coeffs ++ (List.duplicate(0, num_constraints) |> List.replace_at(ix, 1)) ++ [limit]
        ]
      end)

    tableau = [objective | constraints]
    nonbasic_columns = 1..num_variables |> Enum.map(& &1)

    Enum.reduce_while(1..1000, {tableau, nonbasic_columns}, fn _, {tab, nonbasis} ->
      objective = Enum.at(tab, 0)

      if tab |> Enum.at(0) |> Enum.drop(1) |> Enum.all?(&(&1 <= 0)) do
        max = -1 * (tab |> Enum.at(0) |> List.last())

        variables =
          nonbasic_columns
          |> Enum.map(fn col ->
            value =
              tab
              |> Enum.drop(1)
              |> Enum.find([], fn row ->
                Enum.at(row, col) == 1
              end)
              |> List.last(0)

            {col, value}
          end)

        {:halt, {max, variables, objective, nonbasis, tableau}}
      else
        {:cont, step(tab, nonbasis)}
      end
    end)
  end

  def minimise(objective, constraints, num_variables) do
    dual_objective = constraints |> Enum.map(fn {_, _, limit} -> limit end)

    dual_constraints =
      0..(num_variables - 1)
      |> Enum.map(fn variable ->
        {
          constraints |> Enum.map(fn {coeffs, _, _} -> Enum.at(coeffs, variable) end),
          :at_most,
          Enum.at(objective, variable)
        }
      end)

    dual_variables = length(constraints)

    {minimum, _, dual_objective, non_basis, _} =
      maximise(dual_objective, dual_constraints, dual_variables)

    {minimum,
     non_basis
     |> Enum.map(fn col -> {col - dual_variables - 1, -Enum.at(dual_objective, col)} end)}
  end

  defp step(tableau, nonbasic_columns) do
    new_basic_column =
      tableau
      |> Enum.at(0)
      |> Enum.with_index()
      |> Enum.filter(fn {_, ix} -> ix in nonbasic_columns end)
      |> Enum.max_by(fn {val, _} -> val end)
      |> elem(1)

    {old_basic_row, row_ix} =
      tableau
      |> Enum.with_index()
      |> Enum.drop(1)
      |> Enum.reject(fn {row, _} -> Enum.at(row, new_basic_column) <= 0 end)
      |> Enum.min_by(fn {row, _} ->
        List.last(row) / Enum.at(row, new_basic_column)
      end)

    quotient = Enum.at(old_basic_row, new_basic_column)

    replacement_row =
      Enum.map(old_basic_row, &(&1 / quotient))

    tableau = List.replace_at(tableau, row_ix, replacement_row)

    tableau =
      0..(length(tableau) - 1)
      |> Enum.reject(&(&1 == row_ix))
      |> Enum.reduce(tableau, fn mod_row_ix, tab ->
        List.update_at(tab, mod_row_ix, fn mod_row ->
          multiple = Enum.at(mod_row, new_basic_column)
          Enum.zip(mod_row, replacement_row) |> Enum.map(fn {m, r} -> m - multiple * r end)
        end)
      end)

    nonbasic_columns =
      1..((tableau |> Enum.at(0) |> length()) - 2)
      |> Enum.filter(fn ix ->
        tableau |> Enum.at(0) |> Enum.at(ix) != 0
      end)

    {tableau, nonbasic_columns}
  end
end

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
        |> String.codepoints()
        |> Enum.reverse()
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
    |> Enum.map(fn %{toggles: toggles, joltages: jolts} ->
      button_count = length(toggles)
      objective = List.duplicate(1, button_count)

      constraints =
        jolts
        |> Enum.with_index()
        |> Enum.map(fn {value, ix} ->
          {
            toggles
            |> Enum.map(fn controlled ->
              if ix in controlled, do: 1, else: 0
            end),
            :at_least,
            value
          }
        end)

      {minimum, _} =
        Simplex.minimise(objective, constraints, button_count)

      minimum
    end)
    |> Enum.sum()
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

# Simplex.maximise([2, 3, 4, 0, 0], [[3, 2, 1, 1, 0, 10], [2, 5, 3, 0, 1, 15]], 3) |> IO.inspect()
# Simplex.maximise([40, 30, 0, 0], [[1, 1, 1, 0, 12], [2, 1, 0, 1, 16]], 2) |> IO.inspect()

# Simplex.maximise(
#   [3, 1, 2, 0, 0, 0],
#   [
#     {[1, 1, 3, 1, 0, 0], :at_most, 30},
#     {[2, 2, 5, 0, 1, 0], :at_most, 24},
#     {[4, 1, 2, 0, 0, 1], :at_most, 36}
#   ],
#   3
# )
# |> IO.inspect()

# Simplex.minimise([12, 16], [{[1, 2], :at_least, 40}, {[1, 1], :at_least, 30}], 2) |> IO.inspect()

# Simplex.minimise(
#   [1, 1, 1, 1, 1, 1],
#   [
#     {[0, 0, 0, 0, 1, 1], :at_least, 3},
#     {[0, 1, 0, 0, 0, 1], :at_least, 5},
#     {[0, 0, 1, 1, 1, 0], :at_least, 4},
#     {[1, 1, 0, 1, 0, 0], :at_least, 7}
#   ],
#   6
# )
# |> IO.inspect()
