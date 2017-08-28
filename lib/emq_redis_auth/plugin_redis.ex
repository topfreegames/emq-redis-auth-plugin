defmodule EmqRedisAuth.Redis do
  @redis_instances String.to_integer(System.get_env("REDIS_AUTH_REDIS_POOL_SIZE") || "5")

  def command(command) do
    {:ok, result} = Redix.command(:"redix_#{random_index()}", command)
    result
  end

  defp random_index do
    rem(System.unique_integer([:positive]), @redis_instances)
  end
end
