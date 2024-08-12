# Todo

elixir in action from chapter 7

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `todo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:todo, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/todo>.

## commands history

iex -S mix

Todo.Supervisor.start_link

bobs_list = Todo.Cache.server_process("bobs_list")

Todo.ProcessRegistry.whereis_name({:database_worker, 2})

Todo.ProcessRegistry.whereis_name({:database_worker, 2}) |> Process.exit(:kill)

Todo.Server.entries(bobs_list, {2013,12,19})

Todo.Server.add_entry(bobs_list,%{date: {2024,8,14}, title: "Engineer"})

Todo.Server.entries(bobs_list, nil)
