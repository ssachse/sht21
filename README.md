# SHT21

A modul to read data from SHT21 temperature and humidity sensor on an
embedded system.

Thank you to the team of https://github.com/nerves-project
to make it possible to use elixir on embedded systems.

## Features
* Access to a SHT21 sensor that is connected via i2c
* GenServer based
* Intervall based reading of temperature and humidity values in °C
* Collecting min and max values
* Direct reading of sensor
* Buffered reading of sensor

## Setup

Include :sht21 as a dependency and application in your mix.exs.

```elixir
# add as an application to start
def application, do: [
  ...
  applications: [:sht21],
  ...
]

# add to your dependencies
def deps do
  [.....
  {:sht21, github: "ssachse/sht21"},
  ....]
end
```

```elixir
SHT21.setup :sht21, intervall: <value in ms>
```


buffered reading
```elixir
SHT21.read_sensor(:sht21)
```

direct reading
```elixir
SHT21.direct_read_sensor(:sht21)
```

## Work List
- [ ] Finish documentation
- [ ] Implement Alarms with GenEvent




## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add sht21 to your list of dependencies in `mix.exs`:

        def deps do
          [{:sht21, "~> 0.0.1"}]
        end

  2. Ensure sht21 is started before your application:

        def application do
          [applications: [:sht21]]
        end

