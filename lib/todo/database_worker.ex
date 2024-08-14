defmodule Todo.DatabaseWorker do
	use GenServer

	def start_link(db_folder) do
		GenServer.start_link(__MODULE__, db_folder)
	end
	def store(pid, key, data) do
		GenServer.cast(pid, {:store, key, data})
	end
	def get(pid, key) do
		GenServer.call(pid, {:get, key})
	end

	# callbacks
	def init(db_folder) do
		IO.puts "Starting database worker"
		{:ok, db_folder}
	end

	def handle_cast({:store, key, data},  db_folder) do
		IO.puts "databaseworker handle_cast db_folder: #{db_folder}, key: #{key}"
		file_name(db_folder, key)
		|> File.write!(:erlang.term_to_binary(data))
		{:noreply, db_folder}
	end
	def handle_call({:get, key}, _, db_folder) do
		data = case File.read(file_name(db_folder, key)) do
						 {:ok, contents} -> :erlang.binary_to_term(contents)
						 _ -> nil
					 end

		{:reply,data, db_folder}
	end

	defp file_name(db_folder, key) do
		IO.puts "maybe bug here ? #{key}"
		"#{db_folder}/#{key}"
	end
end
