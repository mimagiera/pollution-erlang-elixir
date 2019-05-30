defmodule PollutionData do
  @moduledoc false
  def import(filename \\"pollution.csv") do
    File.read!(filename) |> String.split() |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    [date, time, longitude, latitude, value] = String.split(line, ",")
    date_processed = String.split(date, "-") |> Enum.map(&String.to_integer/1) |> Enum.reverse() |> :erlang.list_to_tuple()
    time_processed = (String.split(time, ":") ++["0"]) |> Enum.map(&String.to_integer/1) |> :erlang.list_to_tuple()
    datetime = [date_processed, time_processed] |> :erlang.list_to_tuple()
    coordinates = {String.to_float(longitude), String.to_float(latitude)}
    value = case String.contains?(value, ".") do
      true -> String.to_float(value)
      _ -> String.to_float(value <> ".0")
    end
    %{:datetime => datetime,:coordinates => coordinates, :value => value}
  end

  def unique_stations(measurements) do
    Enum.uniq_by(measurements, fn(measurement) -> measurement.coordinates end)
  end

  def start_all() do
    measurements = import()
    :pollution_gen_server.start()
    fn() -> add_stations(measurements) end |> :timer.tc |> elem(0) |> Kernel./(1_000_000) |> IO.puts
    fn() ->add_measurements(measurements)  end |> :timer.tc |> elem(0) |> Kernel./(1_000_000) |> IO.puts
    fn() -> :pollution_gen_server.getStationMean({20.06, 49.986}, "PM10") end |> :timer.tc |> elem(0) |> Kernel./(1_000_000) |> IO.puts
    :pollution_gen_server.getStationMean({20.06, 49.986}, "PM10") |> IO.puts
    fn()  -> :pollution_gen_server.getDailyMean("PM10",{2017, 5, 3}) end |> :timer.tc |> elem(0) |> Kernel./(1_000_000) |> IO.puts
    :pollution_gen_server.getDailyMean("PM10",{2017, 5, 3}) |> IO.puts
  end

  def add_stations(measurements) do
    unique = unique_stations(measurements)
    Enum.map(unique, fn(station) -> :pollution_gen_server.addStation(get_name(station), station.coordinates) end)
  end

  def add_measurements(measurements) do
    Enum.map(measurements, fn(measurement) -> :pollution_gen_server.addValue(get_name(measurement), measurement.datetime, "PM10", measurement.value) end)
  end

  def get_name(station) do
     "station_#{elem(station.coordinates,0)}_#{elem(station.coordinates,1)}"
  end

end
