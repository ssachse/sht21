defmodule SHT21.Mixfile do
  use Mix.Project

  def project do
    [app: :sht21,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
     [{:elixir_ale, "~> 0.4.1" },
      {:nerves, github: "nerves-project/nerves"}
     ]
  end
end
