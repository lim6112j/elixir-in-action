defmodule Todo.Database do
	use GenServer
	@pool_size 3
	@db_folder  "./persist"

  def child_spec(_) do
		File.mkdir_p!(@db_folder)
		:poolboy.child_spec(__MODULE__, poolboy_config(),[@db_folder])
  end
	defp poolboy_config do
		[
			name: {:local, __MODULE__},
			worker_module: Todo.DatabaseWorker,
			size: @pool_size,
		]
	end

	def store(key, data) do
		:poolboy.transaction(__MODULE__, fn worker_pid->
			Todo.DatabaseWorker.store(worker_pid, key, data)
		end)
	end
	def get(key) do
		:poolboy.transaction(
			__MODULE__,
			fn worker_pid ->
				Todo.DatabaseWorker.get(worker_pid, key)
			end
		)
	end

	def init(@db_folder) do
		IO.puts "starting database..."
		{:ok, @db_folder}
	end

end
