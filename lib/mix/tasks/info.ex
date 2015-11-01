defmodule Mix.Tasks.Info do
  use Mix.Task

  @shortdoc "Display project code info"

  @moduledoc """
  A mix task to display code information like number of modules, functions,
  lines of codes etc
  """
  def run([]) do
    #info is used as an accumulator
    scanned_dirs = ["lib", "test"]
    info =
    scanned_dirs
      |> Enum.map(&process_dir/1)
      |> merge_results

    display(info)
  end

  defp process_dir(path) do
    case File.ls(path) do
      {:ok, content} ->
        #files
        files = content
          |> Enum.map(&(Path.join(path, &1)))
          |> Enum.filter(&(not File.dir?(&1)))

        #process files
        files_info = files
          |> Enum.map(&process_file/1)
          |> merge_results


        #dirs
        dirs_info = content
          |> Enum.map(&(Path.join(path, &1)))
          |> Enum.filter(&File.dir?/1)
          |> Enum.map(&process_dir/1)
          |> merge_results

        merge_results([[{:dirs, 1}], dirs_info, files_info])

      {:error, :enoent} -> Mix.Shell.IO.error("#{path} No such file or directory")
    end
  end

  defp process_file(path) do
    IO.puts(path)
    File.stream!(path)
      |> Enum.map(fn(line) ->
          cond do
            #skip regular expressions
            line =~ ~r/line =~/   -> [{:lines, 1}]
            line =~ ~r/\s#/       -> [{:comments, 1}, {:lines, 1}]
            line =~ ~r/defmodule/ -> [{:modules, 1}, {:lines, 1}]
            line =~ ~r/defp/      -> [{:private_functions, 1}, {:lines, 1}]
            line =~ ~r/def/       -> [{:functions, 1}, {:lines, 1}]
            true                  -> [{:lines, 1}]
          end
        end)
      |> merge_results
      |> merge_results [{:files,1}]
  end

  # Display the results in a nice formatted way
  # TODO: the nice formatted way
  defp display(info) when is_list(info) do
    config = Mix.Project.config
    IO.puts "Application : #{config[:app]}"
    IO.puts "version : #{config[:version]}"
    IO.inspect(info)
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
