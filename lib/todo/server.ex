defmodule Todo.Server do
	use GenServer
	def start(server_name) do
		GenServer.start(__MODULE__, server_name)
	end

	@impl true
	def init(server_name) do
		send(self(), :real_init)
		{:ok, nil}
	end
	def add_entry(todo_server, new_entry) do
		GenServer.cast(todo_server, {:add_entry, new_entry})
	end

	def entries(todo_server, date) do
		GenServer.call(todo_server, {:entries, date})
	end

	@impl true
	def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
		new_state = Todo.List.add_entry(todo_list, new_entry)
		Todo.Database.store(name, new_state)
		{:noreply, {name, new_state}}
	end

	@impl true
	def handle_call({:entries, date}, _, todo_list) do
		{
			:reply,
			Todo.List.entries(todo_list, date),
			todo_list
		}
	end

	@impl true
	def handle_info(:read_init, state) do
		{:ok, {state, Todo.Database.get(state) || Todo.List.new}}
	end

end
