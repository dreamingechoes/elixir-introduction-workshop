defmodule ElixirTwitterBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_twitter_bot,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ElixirTwitterBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # This will add Plug and Cowboy
      {:plug_cowboy, "~> 2.0"},
      # This will add Jason
      {:jason, "~> 1.1"},
      # This will add ExTwitter
      {:extwitter, "~> 0.9"}
    ]
  end
end
