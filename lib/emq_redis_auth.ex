defmodule EmqRedisAuth do
  use Application

  def start(_type, _args) do
    {:ok, supervisor} = EmqRedisAuth.Supervisor.start_link()
    :emqttd_access_control.register_mod(:auth, EmqRedisAuth.AuthBody, [])
    :emqttd_access_control.register_mod(:acl, EmqRedisAuth.AclBody, [])
    {:ok, supervisor}
  end

  def stop(_app) do
  end

end
