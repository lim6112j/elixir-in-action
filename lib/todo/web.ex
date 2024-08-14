defmodule Todo.Web do
	use Plug.Router
	plug :match
	plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Poison)
	plug :dispatch
	def child_spec(_arg) do
		Plug.Cowboy.child_spec(
			scheme: :http,
			options: [port: 5454],
			plug: __MODULE__
		)
	end
	def init(_) do
		{:ok, nil}
	end
	post "/add_entry" do
		conn = Plug.Conn.fetch_query_params(conn)
		list_name = Map.fetch!(conn.params,"list")
		title = Map.fetch!(conn.params, "title")
		date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))
		list_name
		|> Todo.Cache.server_process()
		|> Todo.Server.add_entry(%{title: title, date: date})
		conn
		|> Plug.Conn.put_resp_content_type("text/plain")
		|> Plug.Conn.send_resp(200, "OK")
	end
	get "/entries" do
		conn = Plug.Conn.fetch_query_params(conn)
		list_name = Map.fetch!(conn.params, "list")
		date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))
		entries = list_name
		|> Todo.ProcessRegistry.whereis_name()
		|> Todo.Server.entries(date)

		conn
		|> Plug.Conn.put_resp_content_type("application/json")
		|> Plug.Conn.send_resp(200, Poison.encode!( %{response: entries}))
	end

end
