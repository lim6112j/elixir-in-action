defmodule Todo.Database do
	use GenServer
	@pool_size 3
	@db_folder  "./persist"
	def start_link do

		# GenServer.start_link(__MODULE__, @db_folder, name: :database_server)
		Todo.PoolSupervisor.start_link(@db_folder, @pool_size)
	end
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
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
		# GenServer.call(:database_server, {:choose_worker, key})
		:erlang.phash2(key, @pool_size) + 1
	end

	def init(@db_folder) do
		IO.puts "starting database..."
		{:ok, @db_folder}
	end

end
