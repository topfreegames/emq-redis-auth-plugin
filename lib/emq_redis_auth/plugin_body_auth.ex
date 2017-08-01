defmodule EmqRedisAuth.AuthBody do
  require EmqRedisAuth.Compat

  @behaviour :emqttd_auth_mod

  def init(params) do
    {:ok, params}
  end

  def check(args, password, _Opts) do
    username = EmqRedisAuth.Compat.mqtt_client(args, :username)
    db_string = get_user(username)
    if db_string != nil and test_password(db_string, password) do
      {:ok, is_superuser?(username)}
    else
      {:error, :invalid_credentials}
    end
  end

  def description do
    "Authentication with Redis, based on mosquitto auth"
  end

  def command(command) do
    {:ok, result} = Redix.command(:"redix_#{random_index()}", command)
    result
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

  defp is_superuser?(user) do
    String.starts_with?(user, "admin_")
  end

  defp get_user(user) do
    response = command(["GET", user])
    if response != nil do
      response
    end
  end

  defp random_index do
    rem(System.unique_integer([:positive]), 5)
  end
end