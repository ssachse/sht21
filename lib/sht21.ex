defmodule SHT21 do
 @moduledoc """
  Manages a SHT21-Sensor on a nerves-based system.
  
  # THIS MODULE NOT READY YET! #
  ## Usage
  ```elixir
  ```
  """

  use Application
  require Logger


  @type sensor :: Atom
  @type settings :: Keyword.t
  @type read_sensor :: Keyword.t
  @type reason :: any

  def start(_type, _args) do
    Logger.debug "#{__MODULE__} Starting"
    SHT21.Subsystem.initialize
    {:ok, self}  
  end

  @doc """
  Configure and start managing a SHT21 sensor.
  """
  @spec setup(sensor, settings) :: {:ok, pid} | {:error, reason}
  def setup(sensor, settings \\ []) do
    Logger.debug "#{__MODULE__} Setup(#{sensor}, #{inspect settings})"
    GenServer.start(SHT21.Server, {sensor, settings},
                    [name: sensor_process(sensor)])
  end

  @doc """
  Return the current settings on an sensor.
  """
  @spec settings(sensor) :: settings
  def settings(sensor) do
    sensor
    |> sensor_process
    |> GenServer.call :settings
  end

  @doc """
  Make a (buffered) reading from the sensor
  So the sensor will not be blocked
  """
  @spec read_sensor(sensor) :: read_sensor
  def read_sensor(sensor) do
    sensor
    |> sensor_process
    |> GenServer.call :read_sensor
  end

  @doc """
  Make a direct reading from the sensor.
  """
  @spec direct_read_sensor(sensor) :: read_sensor
  def direct_read_sensor(sensor) do
    sensor
    |> sensor_process
    |> GenServer.call :direct_read_sensor
  end

  # return a process name for a process
  defp sensor_process(sensor), do: sensor

end
