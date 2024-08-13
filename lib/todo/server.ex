defmodule Todo.Server do
	use GenServer, restart: :temporary
	def start_link(server_name) do
		IO.puts "starting todo server for #{server_name}"
		GenServer.start_link(__MODULE__,server_name, name: via_tuple(server_name))
	end

	@impl true
	def init(server_name) do
		{:ok, {server_name, nil}, {:continue, :init}}
	end
	def add_entry(todo_server, new_entry) do
		IO.puts "Todo.Server.add_entry argument, new_entry : #{inspect(new_entry)}"
		GenServer.cast(todo_server, {:add_entry, new_entry})
	end

	def entries(todo_server, date \\ nil) do
		GenServer.call(todo_server, {:entries, date})
	end
	def via_tuple(name) do
		{:via, Todo.ProcessRegistry, "todo server register", "possible?"}
		{:via, Todo.ProcessRegistry, name}
	end
	def whereis(name) do
		Todo.ProcessRegistry.whereis_name(name)
	end

	@impl true
	def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
		IO.puts "Todo.Server handle_cast: add_entry , todo_list = #{inspect(todo_list)}"
		new_state = Todo.List.add_entry(todo_list, new_entry)
		Todo.Database.store(name, new_state)
		{:noreply, {name, new_state}}
	end

	@impl true
	def handle_call({:entries, date}, _, {name, todo_list}) do
		IO.puts "current todo_list : #{inspect(todo_list)}"
		{
			:reply,
			Todo.List.entries(todo_list, date),
			{name, todo_list}
		}
	end

	@impl true
	def handle_info(:read_init, state) do
		{:noreply, {state, Todo.Database.get(state) || Todo.List.new}}
	end
	@impl true
	def handle_continue(:init, {name, nil}) do
		todo_list = Todo.Database.get(name) || Todo.List.new
		{:noreply, {name, todo_list}}
	end


end
