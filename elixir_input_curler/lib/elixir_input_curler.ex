defmodule ElixirInputCurler do
  def input_for(day) do
    HTTPoison.get!("https://adventofcode.com/2025/day/#{day}/input",
      Cookie: "session=#{System.get_env("AOC_SESSION")}"
    ).body
    |> String.trim()
  end
end
