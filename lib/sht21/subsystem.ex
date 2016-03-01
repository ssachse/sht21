defmodule SHT21.Subsystem do

  @moduledoc """
    Interface to the Senserion SHT21 Humidity and Temperatur Sensor IC

    Reference:
    https://www.sensirion.com/fileadmin/user_upload/customers/sensirion/Dokumente/Humidity_Sensors/Sensirion_Humidity_Sensors_SHT21_Datasheet_V4.pdf
    https://www.sensirion.com/de/produkte/digitale-feuchtesensoren-fuer-zuverlaessige-messungen/feuchte-temperatursensor-sht2x-digital-i2c-genauigkeit/
    https://www.sensirion.com/fileadmin/user_upload/customers/sensirion/Dokumente/Sample_Codes_Software/Humidity_Sensors/Sensirion_Humidity_Sensors_SHT21_Sample_Code_C-file.zip
    https://www.sensirion.com/fileadmin/user_upload/customers/sensirion/Dokumente/Humidity_Sensors/Sensirion_Humidity_Sensors_SHT2x_CRC_Calculation_V1.pdf
  """

  require Logger
  use Bitwise

  @type reason :: any
  @type serial_number :: String.t
  @type sensor :: String.t

  @i2c_address 0x40

  @trig_t_measurement_hm     0xE3 # command trig. temp meas. hold master
  @trig_rh_measurement_hm    0xE5 # command trig. humidity meas. hold master
  @trig_t_measurement_poll   0xF3 # command trig. temp meas. no hold master
  @trig_rh_measurement_poll  0xF5 # command trig. humidity meas. no hold master
  @user_reg_w                0xE6 # command writing user register
  @user_reg_r                0xE7 # command reading user register
  @soft_reset                0xFE # command soft reset



  @doc "Initialize the SHT21 subsystem"
  @spec initialize() :: {:ok, serial_number} | {:error, reason}
  def initialize do
    Logger.debug "initializing SHT21 Subsystem"
    get_sensor_serial_number
  end

  def read_sensor do
    case I2c.start_link(Application.get_env(:sht21, :i2c_bus), @i2c_address) do
      {:ok, pid}       -> get_sensor(pid) 
      {:error, reason} -> Logger.error "SHT21 Serial Number: Could not read from I2c address #{@i2c_address}: #{reason}" 
    end
  end


  def get_sensor_serial_number do
    case I2c.start_link(Application.get_env(:sht21, :i2c_bus), @i2c_address) do
      {:ok, pid} ->  # read memory location 1
                     I2c.write(pid, <<0xfa, 0x0f>>) 
                     :timer.sleep 50
                     mem1 = I2c.read(pid, 8)
                     # read memory location 2
                     I2c.write(pid, <<0xfc, 0xc9>>) 
                     :timer.sleep 50
                     mem2 = I2c.read(pid, 6)
                     snumber = mem1 <> mem2 |> decode_serial_number
                     {:ok, snumber}
      {:error, reason} -> Logger.error "SHT21 Serial Number: Could not read from I2c address #{@i2c_address}: #{reason}" 
    end
  end

  defp decode_serial_number(<<snb_3::size(8), _crc_snb_3::size(8), 
                              snb_2::size(8), _crc_snb_2::size(8), 
                              snb_1::size(8), _crc_snb_1::size(8), 
                              snb_0::size(8), _crc_snb_0::size(8), 
                              snc_1::size(8),      snc_0::size(8), _crc_snc::size(8), 
                              sna_1::size(8),      sna_0::size(8), _crc_sna::size(8) >>) do 
     # CRC not checked
     <<sna::size(16), snb::size(32), snc::size(16)>> = <<sna_0, sna_1, snb_0, snb_1, snb_2, snb_3, snc_0, snc_1>>
     "#{sna}-#{snb}-#{snc}"
  end

  defp get_sensor(pid) do
    # We do a "no hold master" communication sequence
    
    # Soft reset sensor
    I2c.write(pid, << @soft_reset >>)
    :timer.sleep 50
    
    # read temperature
    I2c.write(pid, << @trig_t_measurement_poll >>)
    :timer.sleep 260

    temp = I2c.read(pid, 3) |> decode_temperature

    # read humidity
    I2c.write(pid, << @trig_rh_measurement_poll >>)
    :timer.sleep 60

    humid = I2c.read(pid, 3) |> decode_humidity
    [temperature: temp, humidity: humid]
  end
  
  defp ignore_status_bits(val), do: band(val, bnot(0x0003))

  defp decode_temperature(<<val::size(16), crc::size(8)>>) do
    -46.85 +175.72*ignore_status_bits(val)/65536 |> Float.round(1)
  end
  

  defp decode_humidity(<<val::size(16), crc::size(8)>>) do
    -6 + 125*ignore_status_bits(val)/65536 |> Float.round(1)
  end

end
