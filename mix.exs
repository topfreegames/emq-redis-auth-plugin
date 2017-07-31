defmodule EmqRedisAuth.Mixfile do
  use Mix.Project

  def project do
    [app: :emq_redis_auth,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      extra_applications: [:logger, :redix, :pbkdf2],
      mod: {EmqRedisAuth, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      # {:pbkdf2, "~> 2.0"},
      # {:redix, ">= 0.0.0"},
      # {:distillery, "~> 1.4", runtime: false},
    ]
  end
end
