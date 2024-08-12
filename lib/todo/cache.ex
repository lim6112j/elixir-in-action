defmodule Todo.Cache do
	use GenServer
	def start_link do
		IO.puts "Starting todo cache."
#		GenServer.start_link(__MODULE__, nil, name: :todo_cache)
		DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
	end
	def child_spec(_arg) do
		%{
			id: __MODULE__,
			start: {__MODULE__, :start_link, []},
			type: :supervisor
		}
	end

	def server_process( todo_list_name) do
#		GenServer.call(:todo_cache, {:server_process, todo_list_name})
		case start_child(todo_list_name) do
			{:ok, pid} -> pid
			{:error, {:already_started, pid}} ->
				IO.puts "server process already present !!"
				pid
		end

	end
	defp start_child(name) do
		DynamicSupervisor.start_child(__MODULE__, {Todo.Server, name})
	end

	@impl true
	def init(_) do
		{:ok, %{}}
	end

	# @impl true
	# def handle_call({:server_process, todo_list_name},_, todo_servers) do
	# 	case Map.fetch(todo_servers, todo_list_name) do
	# 		{:ok, todo_server} ->
	# 			{:reply, todo_server, todo_servers}
	# 		:error ->
	# 			{:ok, new_server} = Todo.Server.start_link(todo_list_name)
	# 			{
	# 				:reply,
	# 				new_server,
	# 				Map.put(todo_servers, todo_list_name, new_server)
	# 			}
	# 	end

	# end

end
