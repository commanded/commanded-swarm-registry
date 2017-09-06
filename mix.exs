defmodule Commanded.Registration.SwarmRegistry.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :commanded_swarm_registry,
      version: @version,
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/commanded/commanded-swarm-registry",
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
      ]
    ]
  end

  defp deps do
    [
      {:commanded, path: "~/src/commanded", runtime: false},
      {:swarm, "~> 3.0"},
    ]
  end

  defp description do
"""
Distributed process registry using Swarm for Commanded
"""
  end

  defp elixirc_paths(:test),  do: ["lib", "test/support"]
  defp elixirc_paths(_),      do: ["lib"]

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Ben Smith"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/commanded/commanded-swarm-registry",
               "Docs" => "https://hexdocs.pm/commanded_swarm_registry/"}
    ]
  end
end
