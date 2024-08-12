defmodule Todo.List do
	defstruct next_id: 1, entries: %{}
	def new(entries \\ []) do
		Enum.reduce(
			entries,
			%Todo.List{},
			&add_entry(&1, &2)
		)
	end
	def add_entry(todo_list, entry) do
		entry = Map.put(entry, :id, todo_list.next_id)
		new_entries = Map.put(todo_list.entries, todo_list.next_id, entry)
		%Todo.List{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
	end
	def entries(todo_list, date) do
		case date do
			nil -> todo_list.entries |> Map.values()
			_ ->
				todo_list.entries
				|> Map.values()
				|> Enum.filter(fn entry -> entry.date == date end)
		end
	end

end
