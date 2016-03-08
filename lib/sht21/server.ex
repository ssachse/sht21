defmodule SHT21.Server do

  @moduledoc false

  alias SHT21.Subsystem

  require Logger
  use Timex

  @public_keys [
    :sensor, :sensorname, :serial_number, :temperature, :humidity, :intervall, :temp_alarm, :humidity_alarm
  ]

  def init({sensor, settings}) do
    Logger.debug "SHT21.Server(#{inspect sensor}): #{inspect settings}"
    [sensor: sensor, sensorname: "sht21", intervall: 5000, 
     temp_max: 0, temp_max_alarm: 40, temp_min: 200, temp_min_alarm: -40, 
     humidity_min: 200, humidity_max: 0, humidity_min_alarm: 0, humidity_max_alarm: 90]
    |> Keyword.merge(settings)
    |> setup_sensor()
    |> respond(:ok)
  end


  def handle_call(:read_sensor, _from, state) do
    {:reply, Keyword.take(state,[:temperature, :humidity, :at]), state }
  end

  def handle_call(:direct_read_sensor, _from, state) do
    at  = Date.now |> DateFormat.format!("%I:%M:%S", :strftime)
    sensor_reading = Subsystem.read_sensor |> Keyword.merge([at: at])
    {:reply, sensor_reading, state }
  end

  def handle_info(:do_intervall, state) do
    at  = Date.now |> DateFormat.format!("%I:%M:%S", :strftime)
    sensor_data = Subsystem.read_sensor
    new_state = state 
                  |> Keyword.merge([at: at])
                  |> Keyword.merge(sensor_data) 
                  |> update_min_max_values(sensor_data)

                  #IO.inspect new_state
    {:noreply, new_state }
  end

  defp update_min_max_values(state, sensor_data) do
    new_state = state 
                  |> Keyword.put(:temp_max, max(state[:temp_max], sensor_data[:temperature]))
                  |> Keyword.put(:temp_min, min(state[:temp_min], sensor_data[:temperature]))
                  |> Keyword.put(:humidity_max, max(sensor_data[:humidity], state[:humidity_max]))
                  |> Keyword.put(:humidity_min, min(sensor_data[:humidity], state[:humidity_min]))  
  end

  def handle_call(:read_serial_number, _from, state) do
    {:reply, Keyword.get(state, :serial_number), state}
  end

  def handle_call(:settings, _from, state) do
    {:reply, settings(state), state}
  end

  # return keys from state that are included in "settings"
  defp settings(state) do
    Keyword.take(state, @public_keys)
  end

  # given settings, apply to state, and setup interface accordingly
  defp setup_sensor(state) do
    Logger.debug "setup_sensor(#{inspect state})"
    if state[:intervall] > 0 do
      :timer.send_interval(state[:intervall], self(), :do_intervall)
    end
    state |> Keyword.merge([serial_number: Subsystem.get_sensor_serial_number])
  end


  # update changes and announce, returning new state
  defp update_and_announce(state, changes) do
    public_changes = Keyword.take changes, @public_keys
    if Enum.any?(public_changes) and state[:on_change] do
      state.on_change.(public_changes)
    end
    Keyword.merge(state, changes)
  end


  defp respond(t, atom), do: {atom, t}

end
