Mix.install([{:elixir_input_curler, path: "../elixir_input_curler"}])

defmodule Day08Elixir do
  def part_one(data, links) do
    nodes = parse(data)
    distances = calc_distances(nodes)
    base_cliques = Enum.map(0..(length(nodes) - 1), &MapSet.new([&1]))

    cliques =
      distances
      |> Enum.take(links)
      |> Enum.reduce(base_cliques, fn {{from, to}, _}, builder ->
        from_clique = Enum.find_index(builder, &MapSet.member?(&1, from))
        to_clique = Enum.find_index(builder, &MapSet.member?(&1, to))

        case {from_clique, to_clique} do
          {nil, nil} ->
            [MapSet.new([from, to]) | builder]

          {_, nil} ->
            List.update_at(builder, from_clique, &MapSet.put(&1, to))

          {nil, _} ->
            List.update_at(builder, to_clique, &MapSet.put(&1, from))

          {a, b} when a != b ->
            builder
            |> List.update_at(from_clique, &MapSet.union(&1, Enum.at(builder, to_clique)))
            |> List.delete_at(to_clique)

          {a, b} when a == b ->
            builder
        end
      end)

    cliques |> Enum.map(&MapSet.size/1) |> Enum.sort(:desc) |> Enum.take(3) |> Enum.product()
  end

  def part_two(data) do
    nodes = parse(data)
    distances = calc_distances(nodes)
    base_cliques = Enum.map(0..(length(nodes) - 1), &MapSet.new([&1]))

    {last_a, last_b} =
      distances
      |> Enum.reduce_while(base_cliques, fn {{from, to}, _}, builder ->
        from_clique = Enum.find_index(builder, &MapSet.member?(&1, from))
        to_clique = Enum.find_index(builder, &MapSet.member?(&1, to))

        builder =
          case {from_clique, to_clique} do
            {nil, nil} ->
              [MapSet.new([from, to]) | builder]

            {_, nil} ->
              List.update_at(builder, from_clique, &MapSet.put(&1, to))

            {nil, _} ->
              List.update_at(builder, to_clique, &MapSet.put(&1, from))

            {a, b} when a != b ->
              builder
              |> List.update_at(from_clique, &MapSet.union(&1, Enum.at(builder, to_clique)))
              |> List.delete_at(to_clique)

            {a, b} when a == b ->
              builder
          end

        if length(builder) == 1, do: {:halt, {from, to}}, else: {:cont, builder}
      end)

    elem(Enum.at(nodes, last_a), 0) * elem(Enum.at(nodes, last_b), 0)
  end

  def parse(data) do
    data
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn [x, y, z] ->
      {String.to_integer(x), String.to_integer(y), String.to_integer(z)}
    end)
  end

  def calc_distances(nodes) do
    for {{ax, ay, az}, aix} <- nodes |> Enum.with_index(),
        {{bx, by, bz}, bix} <- nodes |> Enum.with_index() |> Enum.drop(aix + 1),
        into: %{} do
      distance_sq =
        ((ax - bx)
         |> abs()
         |> Integer.pow(2)) +
          ((ay - by)
           |> abs()
           |> Integer.pow(2)) +
          ((az - bz)
           |> abs()
           |> Integer.pow(2))

      {{aix, bix}, distance_sq}
    end
    |> Enum.sort_by(fn {_, v} -> v end)
  end
end

sample =
  "162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689"

data = ElixirInputCurler.input_for(8)

IO.puts("Sample one: #{Day08Elixir.part_one(sample, 10)}")
IO.puts("Answer one: #{Day08Elixir.part_one(data, 1000)}")
IO.puts("Sample two: #{Day08Elixir.part_two(sample)}")
IO.puts("Answer two: #{Day08Elixir.part_two(data)}")
