defmodule Liquidizer.Mixfile do
  use Mix.Project

  def project do
    [app: :liquidizer,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:cowboy, :logger, :httpoison],
     mod: {Liquidizer, []}]
  end

  defp deps do
    [
        {:cowboy, "~> 1.0.4"},
        {:plug, "~> 1.2"},
        {:httpoison, "~> 0.9.0"},
    ]
  end
end
