defmodule SHT21.Mixfile do

  @version "0.1.0-dev"

  use Mix.Project

  def project do
    [app: :sht21,
     version: @version,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]],
    mod: {SHT21, []}
  end

  defp deps do
     [{:elixir_ale, "~> 0.4.1" },
      {:earmark, "~> 0.1", only: [:dev, :docs]},
      {:ex_doc, "~> 0.8", only: [:dev, :docs]}
     ]
  end
end
