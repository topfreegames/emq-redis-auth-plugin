defmodule EmqRedisAuthTest do
  use ExUnit.Case, async: true
  doctest EmqRedisAuth
  require EmqRedisAuth.Compat

  @user "such_user"
  @admin_user "admin_much_user"
  @pass "much_password"
  @wtopic "much/chat/write"
  # @wtopic_param [<<"much">>, <<"chat">>, <<"write">>]
  @wtopic_wildcard "much/wildcard/+"
  # @wtopic_wildcard_string "much/wildcard/chat"
  # @wtopic_wildcard_param [<<"much">>, <<"wildcard">>, <<"chat">>]
  # @wtopic_param [<<"much">>, <<"chat">>, <<"write">>]
  @rtopic "much/chat/read"
  # @rtopic_param [<<"much">>, <<"chat">>, <<"read">>]
  @encrypted_pass "PBKDF2$sha256$1000$jpZlWoGyBrmwDn5L$tBZHHs52NErO9tz5exw1QiJ03f5b/bfq"
  @invalid_credentials {:error, :invalid_credentials}
  # @invalid_topic {:error, :invalid_topic}
  @ok {:ok, false}
  @ok_superuser {:ok, true}

  setup_all do
    :emqttd_access_control.start_link()
    {:ok, _emttd_redis_auth} = EmqRedisAuth.start(nil, nil)

    EmqRedisAuth.AuthBody.command(["SET", @admin_user, @encrypted_pass])
    EmqRedisAuth.AuthBody.command(["SET", @user, @encrypted_pass])
    EmqRedisAuth.AuthBody.command(["SET", @user <> "-" <> @wtopic, 2])
    EmqRedisAuth.AuthBody.command(["SET", @user <> "-" <> @wtopic_wildcard, 2])
    EmqRedisAuth.AuthBody.command(["SET", @user <> "-" <> @rtopic, 1])

    {:ok, []}
  end

  test "when user doesn't exist" do
    mqtt_client = EmqRedisAuth.Compat.mqtt_client(username: "not_user")
    assert EmqRedisAuth.AuthBody.check(mqtt_client, "some_pass", []) == @invalid_credentials
  end

  test "when user exist" do
    mqtt_client = EmqRedisAuth.Compat.mqtt_client(username: @user)
    assert EmqRedisAuth.AuthBody.check(mqtt_client, @pass, []) == @ok
  end

  test "when superuser" do
    mqtt_client = EmqRedisAuth.Compat.mqtt_client(username: @admin_user)
    assert EmqRedisAuth.AuthBody.check(mqtt_client, @pass, []) == @ok_superuser
  end
end
