defmodule EmqRedisAuth.AclBody do
  require EmqRedisAuth.Compat
  @wildcard_regex ~r/\/([^\/]+)$/
  @behaviour :emqttd_acl_mod

  def init(params) do
    {:ok, params}
  end

  def check_acl({client, pubsub, topic} = _args, _state) do
    username = EmqRedisAuth.Compat.mqtt_client(client, :username)
    case pubsub do
      :publish -> can_publish_topic?(username, topic)
      :subscribe -> can_subscribe_topic?(username, topic)
      _ -> :deny
    end
  end

  def can_publish_topic?(user, topic) do
    has_permission_on_topic?(user, topic, 1)
  end

  def can_subscribe_topic?(user, topic) do
    has_permission_on_topic?(user, topic, 0)
  end

  def reload_acl(_state), do: :ok

  def description do
    "Authorization with Redis, based on mosquitto auth"
  end

  defp is_superuser?(user) do
    String.starts_with?(user, "admin_")
  end

  defp has_permission_on_topic?(user, topic, permission_number) do
    topic = get_topic(user, topic)
    if topic > permission_number or is_admin?(user) do
      IO.puts("#{user} authorized on topic #{topic}")
      :allow
    else
      IO.puts("#{user} not authorized on topic #{topic}")
      :deny
    end
  end

  defp is_admin?(user) do
    String.starts_with?(user, "admin_")
  end

  defp get_topic_param(user, topic) do
    user <> "-" <> topic
  end

  defp get_topic(user, topic) do
    topic_wildcard =  Regex.replace(@wildcard_regex, topic, "/+")
    redis_response = EmqRedisAuth.Redis.command(["mget", get_topic_param(user, topic), get_topic_param(user, topic_wildcard)])
    response = Enum.at(redis_response, 0) || Enum.at(redis_response, 1)
    if response != nil do
      String.to_integer(response)
    else
      0
    end
  end

end
