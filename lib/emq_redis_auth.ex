defmodule EmqRedisAuth do
  use Application

    def start(_type, _args) do
        EmqRedisAuth.Body.load([])

        # start a dummy supervisor
        EmqRedisAuth.Supervisor.start_link()
    end

    def stop(_app) do
        EmqRedisAuth.Body.unload()
    end

end
