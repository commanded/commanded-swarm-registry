defmodule Commanded.Registration.SwarmRegistry.Mixfile do
  use Mix.Project

  @version "0.3.0"

  def project do
    [
      app: :commanded_swarm_registry,
      version: @version,
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      docs: docs(),
      package: package(),
      source_url: "https://github.com/commanded/commanded-swarm-registry"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:commanded, ">= 0.19.0", runtime: Mix.env() == :test},
      {:swarm, "~> 3.4"},

      # Build & test tools
      {:ex_doc, "~> 0.20", only: :dev},
      {:mox, "~> 0.5", only: :test}
    ]
  end

  defp description do
    """
    Distributed process registry for Commanded using Swarm
    """
  end

  defp docs do
    [
      main: "Commanded.Registration.SwarmRegistry",
      canonical: "http://hexdocs.pm/commanded_swarm_registry",
      source_ref: "v#{@version}",
      extra_section: "GUIDES",
      extras: [
        "guides/Getting Started.md",
        "guides/Cluster.md"
      ]
    ]
  end

  defp elixirc_paths(:test) do
    [
      "lib",
      "test/support",
      "deps/commanded/test/registration/support",
      "deps/commanded/test/support"
    ]
  end

  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Ben Smith"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/commanded/commanded-swarm-registry"
      }
    ]
  end
end
