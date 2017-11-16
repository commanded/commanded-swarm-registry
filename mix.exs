defmodule Commanded.Registration.SwarmRegistry.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :commanded_swarm_registry,
      version: @version,
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      docs: docs(),
      package: package(),
      source_url: "https://github.com/commanded/commanded-swarm-registry",
    ]
  end

  def application do
    [
      extra_applications: extra_applications(Mix.env),
    ]
  end

  defp extra_applications(:test), do: [:logger, :eventstore]
  defp extra_applications(_),     do: [:logger]

  defp deps do
    [
      {:commanded, ">= 0.15.0", runtime: Mix.env == :test},
      {:commanded_eventstore_adapter, ">= 0.3.0", only: :test},
      {:eventstore, ">= 0.13.0", only: :test},
      {:ex_doc, "~> 0.18", only: :dev},
      {:mix_test_watch, "~> 0.5", only: :dev},
      {:swarm, "~> 3.1"},
    ]
  end

  defp description do
"""
Distributed process registry for Commanded using Swarm
"""
  end

  @commanded_elixirc_paths [
    "deps/commanded/test/aggregates/support",
    "deps/commanded/test/commands/support",
    "deps/commanded/test/event/support",
    "deps/commanded/test/example_domain",
    "deps/commanded/test/process_managers/support",
  ]

  defp docs do
    [
      main: "Commanded.Registration.SwarmRegistry",
      canonical: "http://hexdocs.pm/commanded_swarm_registry",
      source_ref: "v#{@version}",
      extra_section: "GUIDES",
      extras: [
        "guides/Getting Started.md",
      ],
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"] ++ @commanded_elixirc_paths
  defp elixirc_paths(_),     do: ["lib"]

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Ben Smith"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/commanded/commanded-swarm-registry",
        "Docs" => "https://hexdocs.pm/commanded_swarm_registry/",
      },
    ]
  end
end
