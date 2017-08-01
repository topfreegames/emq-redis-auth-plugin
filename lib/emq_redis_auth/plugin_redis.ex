defmodule EmqRedisAuth.Redis do
  def command(command) do
    {:ok, result} = Redix.command(:"redix_#{random_index()}", command)
    result
  end

  defp random_index do
    rem(System.unique_integer([:positive]), 5)
  end
end
