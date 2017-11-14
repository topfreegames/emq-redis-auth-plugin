defmodule EmqRedisAuth.AuthBody do
  require EmqRedisAuth.Shared
  require Logger

  @behaviour :emqttd_auth_mod

  def init(params) do
    {:ok, params}
  end

  def check(args, password, _Opts) do
    username = EmqRedisAuth.Shared.mqtt_client(args, :username)
    throttling = incr_throttle(username)
    if throttling > throttling_limit() do
        Logger.error fn ->
          "#{username} exceeded throttling"
        end
        {:error, :invalid_credentials}
    else
      {_, result} = Cachex.get(:auth_cache, "redis_auth" <> username, fallback: fn(_key) ->
        db_string = get_user(username)
        if db_string != nil and test_password(db_string, password) do
          {:ok, EmqRedisAuth.Shared.is_superuser?(username)}
        else
          Logger.error fn ->
            "#{username} not authorized"
          end
          {:error, :invalid_credentials}
        end
      end)
      result
    end
  end

  def description do
    "Authentication with Redis, based on mosquitto auth"
  end

  def test_password(db_string, password) do
    [_, hash_string, iterations_string, salt, db_pass] = String.split(db_string, "$")
    hash = String.to_atom(hash_string)
    iterations = String.to_integer(iterations_string)
    key_length = String.length(db_pass)
    {:ok, res} = :pbkdf2.pbkdf2(
      hash,
      password,
      salt,
      iterations,
      key_length
    )
    result = String.slice(Base.encode64(res), 0, key_length)
    result == db_pass
  end

  defp get_user(user) do
    response = EmqRedisAuth.Redis.command(["GET", user])
    if response != nil do
      response
    end
  end

  defp incr_throttle(user) do
    timeout = String.to_integer(System.get_env("REQUESTS_THROTTLING_TIMEOUT_SEC") || "60")
    key = "throttling_" <> user
    response = EmqRedisAuth.Redis.pipeline([["SET", key, 0, "EX", timeout, "NX"], ["INCR", key]])
    if response != nil do
      [_,value] = response
      value
    end
  end

  defp throttling_limit() do
    String.to_integer(System.get_env("REQUESTS_THROTTLING_LIMIT") || "10")
  end

end
