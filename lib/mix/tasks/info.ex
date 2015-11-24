defmodule Mix.Tasks.Info do
  use Mix.Task

  @shortdoc "Display project code info"
  @recursive true

  @moduledoc """
  A mix task to display code information like number of modules, functions,
  lines of codes etc
  """
  def run([]) do
    Mix.Project.get!
    paths = Path.wildcard("lib/**")
    files = Mix.Utils.extract_files(Path.wildcard("lib/**"), [".ex"])
    files
      |> Enum.map(&process_file/1)
      |> merge_results
      |> merge_results([directories: count_directories(paths -- files)])
      |> Enum.sort
      |> display
  end

  defp count_directories(paths) do
    paths
      |> Enum.map(&(Path.relative_to(&1,"lib")))
      |> Enum.map(&Path.split/1)
      |> Enum.count
  end

  defp process_file(path) do
    File.stream!(path)
      |> Enum.map(fn(line) ->
          striped = String.strip(line)
          #Assumption comments are in their own lines
          res = cond do
            striped =~ ~r/#/       -> [comments: 1]
            striped =~ ~r/^defmodule/ -> [modules: 1]
            striped =~ ~r/^defp/      -> [private_functions: 1]
            striped =~ ~r/^def/       -> [functions: 1]
            striped =~ ~r/^@doc/       -> [docs: 1]
            striped =~ ~r/^@moduledoc/ -> [moduledocs: 1]
            striped =~ ~r/^iex>/       -> [doctests: 1]
            true                  -> []
          end

          merge_results(res, [lines: 1])

        end)
      |> merge_results
      |> merge_results [files: 1]
  end

  # Display the results in a nice formatted way
  defp display(info) when is_list(info) do
    display_title
    info
      |> Enum.map(&display_info/1)
  end

  defp display_title do
    config = Mix.Project.config
    [:yellow, "#{config[:app]}", :white, ": ", :green, "#{config[:version]}", :reset]
      |> IO.ANSI.format
      |> IO.puts
  end

  defp display_info({name, value}) do
    [:blue, name |> Atom.to_string |> String.replace("_", " "), :white, ": #{value}"]
      |> IO.ANSI.format
      |> IO.puts
  end

  # merge a list of results(keyword lists)
  defp merge_results(res) when is_list(res) do
    Enum.reduce(res, Keyword.new, &merge_results/2)
  end

  #merge two keyword lists containing results
  defp merge_results([], []), do: []
  defp merge_results([], res), do: res
  defp merge_results(res, []), do: res
  defp merge_results(res1, res2) do
     Keyword.merge(res1, res2, fn(_, v1, v2) -> v1+v2 end)
  end
end
