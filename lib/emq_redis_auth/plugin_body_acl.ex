defmodule EmqRedisAuth.AclBody do
  require EmqRedisAuth.Compat

  @behaviour :emqttd_acl_mod

  def init(params) do
    {:ok, params}
  end

  def check_acl({client, pubsub, topic} = _args, _state) do
    IO.inspect("check_acl", [client, pubsub, topic])
    :ignore
  end

  def reload_acl(_state), do: :ok

  def description do
    "Authorization with Redis, based on mosquitto auth"
  end

end
