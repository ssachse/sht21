defmodule SHT21.Mixfile do

  @version "0.1.0-dev"

  use Mix.Project

  def project do
    [app: :sht21,
     version: @version,
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     description: "SHT21 Module",
     # Hex
     package: package,
     # ExDoc
     #name: "SMT21",
     #docs: [source_ref: "v#{@version}",
     #       main: "SMT21",
     #       source_url: "https://github.com/ssachse/sht21"]
   ]
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

  defp package, do: [
    maintainers: ["Stefan Sachse"],
    licenses: ["MIT"],
    links: %{github: "https://github.com/ssachse/sht21"},
    files: ~w(lib config) ++
           ~w(README.md CHANGELOG.md LICENSE mix.exs)
  ]

end
