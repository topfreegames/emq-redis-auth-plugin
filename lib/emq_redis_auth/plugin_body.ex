require Record

defmodule EmqRedisAuth.Body do
  @behaviour :emqttd_auth_mod

  Record.defrecord :state, [:auth_cmd, :super_cmd, :hash_type]


  def init(params) do
    {:ok, params}
  end

  def check(user, password, _Opts) do
    IO.inspect(["elixir check", user, password])
  end

  def desciption() do
    "Authentication with Redis, based on mosquitto auth"
  end
end
