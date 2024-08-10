defmodule Todo.Database do
	use GenServer
	@db_folder  "./persist"
	def start() do
		GenServer.start(__MODULE__, @db_folder, name: __MODULE__)
	end
	def store(key, data) do
		key
		|> choose_worker()
		|> Todo.DatabaseWorker.store(key, data)
	end
	def get(key) do
		key
		|> choose_worker()
		|> Todo.DatabaseWorker.get(key)

	end

	defp choose_worker(key) do
		GenServer.call(__MODULE__, {:choose_worker, key})
	end

	def init(@db_folder) do

		File.mkdir_p(@db_folder)
		pid_dict = for index <- 1..3, into: %{} do
				{:ok, pid} = Todo.DatabaseWorker.start(@db_folder)
				{index-1, pid}
		end
		{:ok, pid_dict}
	end


	def handle_cast({:store, key, data}, state) do
		worker_key = :erlang.phash2(key,3)
		worker = Map.get(state, worker_key)
		Todo.DatabaseWorker.store(worker, key, data)
		{:noreply, state}
	end
	def handle_call({:choose_worker, key}, _, state) do
		worker_key = :erlang.phash2(key, 3)
		IO.inspect("worker key is #{worker_key}")
		{:reply, Map.get(state, worker_key), state}
	end



end
