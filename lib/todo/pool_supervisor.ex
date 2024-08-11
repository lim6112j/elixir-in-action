defmodule Todo.PoolSupervisor do
	use Supervisor
	def start_link(db_folder, pool_size) do
		IO.puts "starting pool supervisor making #{pool_size} database worker"
		children = Enum.map(1..pool_size, fn worker_id ->
				Supervisor.child_spec({Todo.DatabaseWorker, {db_folder, worker_id}},
				id: {:database_worker, worker_id})
		end)
		Supervisor.start_link(children, strategy: :one_for_one)
	end

	# callbacks
	def init({db_folder, pool_size}) do
		{:ok, {db_folder, pool_size}}
	end

end
