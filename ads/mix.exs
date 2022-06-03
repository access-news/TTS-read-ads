defmodule Ads.MixProject do
  use Mix.Project

  def project do
    [
      app: :ads,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  @doc """
  NOTE 2022_06_02T2239 TIMEX NEEDS REBAR3!
  Keep this in mind when creating a shell.nix for this
  project.  Right now  it  is  installed locally  into
  /home with `mix deps.get`
  """
  defp deps do
    [ {:castore, "~> 0.1.17"} \
    , {:mint, "~> 1.4"}       \
    , {:jason, "~> 1.3"}      \
    , {:timex, "~> 3.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
