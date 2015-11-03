defmodule Stats.Mixfile do
  use Mix.Project

  def project do
    [app: :mix_info,
     version: "0.7.2",
     elixir: "~> 1.1",
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    []
  end

  defp deps do
    []
  end

  defp description do
    """
    A mix task that counts directories, files, lines of code, modules, functions etc and displays the results.
    """
  end

  defp package do
    files: ["lib", "mix.exs", "README.md", "LICENSE"],
    maintainers: ["Panagiotis Skordilakis"],
    licenses: ["MIT"],
    links: %{"GitHub" => "https://github.com/pskordilakis/mix_info"}
  end
end
