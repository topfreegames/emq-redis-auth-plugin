defmodule EmqRedisAuth.Body do

    def hook_add(a, b, c) do
        :emqttd_hooks.add(a, b, c)
    end

    def hook_del(a, b) do
        :emqttd_hooks.delete(a, b)
    end

    def load(env) do
        hook_add(:"message.publish",
          &EmqRedisAuth.Body.on_message_publish/2,
          [env]
        )
        hook_add(:"client.connected",
          &EmqRedisAuth.Body.on_client_connected/3,
          [env]
        )
        hook_add(:"client.subscribe",
          &EmqRedisAuth.Body.on_client_subscribe/4,
          [env]
        )
    end

    def unload do
        hook_del(:"message.publish",
          &EmqRedisAuth.Body.on_message_publish/2
        )
        hook_del(:"client.connected",
          &EmqRedisAuth.Body.on_client_connected/3
        )
        hook_del(:"client.subscribe",
          &EmqRedisAuth.Body.on_client_subscribe/4
        )
    end

    def on_message_publish(message, env) do
        IO.inspect(["elixir on_message_publish", message, env])
        {:ok, message}
    end

    def on_client_connected(returncode, client, env) do
        IO.inspect(["elixir on_client_connected", client, returncode, client, env])

        :ok
    end

    def on_client_subscribe(clientid, username, topictable, env) do
        IO.inspect(["elixir on_client_subscribe", clientid, username, topictable, env])

        {:ok, topictable}
    end
end
