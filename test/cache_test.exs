defmodule Todo.CacheTest do
	use ExUnit.Case
	test "server process" do
		bob_pid = Todo.Cache.server_process("bob's list")
		assert bob_pid != Todo.Cache.server_process("alice")
		assert bob_pid == Todo.Cache.server_process("bob's list")
	end

end
