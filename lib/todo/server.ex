defmodule Todo.Server do
	use Agent, restart: :temporary
	def start_link(server_name) do
		Agent.start_link(fn ->
			IO.puts "Starting to-dp sever for #{server_name}"
			{server_name, Todo.Database.get(server_name) || Todo.List.new}
		end, name: via_tuple(server_name))
	end

	def add_entry(todo_server, new_entry) do
		IO.puts "Todo.Server.add_entry argument, new_entry : #{inspect(new_entry)}"
		Agent.cast(todo_server, fn {name, todo_list} ->
			new_state = Todo.List.add_entry(todo_list, new_entry)
			Todo.Database.store(name, new_state)
			{name, new_state}
			end)
	end

	def entries(todo_server, date \\ nil) do
		Agent.get(todo_server, fn {_name, todo_list}->
			Todo.List.entries(todo_list, date)
		end)
	end
	def via_tuple(name) do
		{:via, Todo.ProcessRegistry, "todo server register", "possible?"}
		{:via, Todo.ProcessRegistry, name}
	end
	def whereis(name) do
		Todo.ProcessRegistry.whereis_name(name)
	end
end
