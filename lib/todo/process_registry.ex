defmodule Todo.ProcessRegistry do
	use GenServer
	import Kernel, except: [send: 2]
	def start_link(_) do
		GenServer.start_link(__MODULE__, nil, name: __MODULE__)
	end

	def deregister_pid(process_registry, pid) do
		key = process_registry
		|> Enum.find(fn {_key, val} -> val == pid  end)
		|> elem(0)
		Map.pop(process_registry, key)
		|> elem(1)
	end
	def register_name(key, pid) do
		IO.puts "registering name in process registry : #{inspect(key)}"
		GenServer.call(__MODULE__, {:register_name, key, pid})
	end
	def unregister_name(key) do
		GenServer.call(__MODULE__, {:unregister_name, key})
	end
	def registries do
		GenServer.call(__MODULE__, {:registries})
	end

	def whereis_name(key) do
		IO.puts "whereis_name called #{inspect(key)}"
		GenServer.call(__MODULE__, {:whereis_name, key})
	end

	def send(key, message) do
		IO.puts "via key = #{key}, message=#{message}"
		case whereis_name(key) do
			:undefined -> {:badarg, {key, message}}
			pid ->
				Kernel.send(pid, message)
				pid
		end

	end


	# callbacks
	def init(_) do
		{:ok, %{}}
	end
	def handle_call({:registries}, _, process_registry) do
		{:reply, process_registry, process_registry}
	end

	def handle_call({:register_name, key, pid}, _, process_registry) do
		case Map.get(process_registry, key) do
			nil ->
				Process.monitor(pid)
				{:reply, :yes, Map.put(process_registry, key, pid)}
			_ ->
				{:reply, :no, process_registry}
		end
	end
	def handle_call({:unregister_name, key}, _, process_registry) do
		case Map.get(process_registry, key) do
			nil ->
				{:reply, :no, process_registry}
			_ ->
				{pid, new_registry} = Map.pop(process_registry, key)
				Process.demonitor(pid)
				{:reply, :yes, new_registry}
		end
	end

	def handle_call({:whereis_name, key}, _, process_registry) do
		{
			:reply,
			Map.get(process_registry, key, :undefined),
			process_registry
		}
	end
	def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
		Process.exit(pid, :normal)
		{:noreply, deregister_pid(process_registry, pid)}
	end


end
