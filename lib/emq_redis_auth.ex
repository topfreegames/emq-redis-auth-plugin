require Record

defmodule EmqRedisAuth do
  use Application

  def start(_type, _args) do
    # start a dummy supervisor
    {:ok, supervisor} = EmqRedisAuth.Supervisor.start_link()
    :emqttd_access_control.register_mod(:auth, EmqRedisAuth.AuthBody, [])
    {:ok, supervisor}
  end

  def stop(_app) do
  end

end
