defmodule EmqRedisAuth.AclBody do
  require EmqRedisAuth.Compat

  @behaviour :emqttd_acl_mod

  def init(params) do
    {:ok, params}
  end

  def check_acl({client, pubsub, topic} = _args, _state) do
    username = EmqRedisAuth.Compat.mqtt_client(client, :username)
    IO.puts("Username")
    IO.puts(username)

    IO.puts("pubsub")
    IO.puts(pubsub)

    IO.puts("topic")
    IO.puts(topic)

    :ignore
  end

  def reload_acl(_state), do: :ok

  def description do
    "Authorization with Redis, based on mosquitto auth"
  end

end
