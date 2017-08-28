defmodule EmqRedisAuth.AclBody do
  require EmqRedisAuth.Shared
  require Logger
  @wildcard_regex ~r/\/([^\/]+)$/
  @behaviour :emqttd_acl_mod

  def init(params) do
    {:ok, params}
  end

  def check_acl({client, pubsub, topic} = _args, _state) do
    username = EmqRedisAuth.Shared.mqtt_client(client, :username)
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

  defp has_permission_on_topic?(user, topic, permission_number) do
    case EmqRedisAuth.Shared.is_superuser?(user) or acl_as_boolean(user, topic, permission_number) do
      true ->
        Logger.debug fn ->
          "#{user} authorized on topic #{topic}"
        end
        :allow
      false ->
        Logger.error fn ->
          "#{user} not authorized on topic #{topic}"
        end
        :deny
    end
  end

  defp acl_as_boolean(user, topic, permission_number) do
    topic_response = get_topic(user, topic)
    topic_response > permission_number
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
