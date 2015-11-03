# Mix Info

A mix task that counts directories, files, lines of code, modules, functions etc and displays the results.

## Installation

  1. Add mix_info to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
      [{:mix_info, "~> 0.7.2"}]
  end
  ```
  2. Update your dependencies

  ```sh-session
  $ mix deps.get
  ```

## Usage

Just run `mix info`

```sh-session
$ mix info
Application : mix_info
version : 0.7.2
directories : 4
files : 1
lines : 94
modules : 1
functions : 1
private functions : 8
comments : 19
```
