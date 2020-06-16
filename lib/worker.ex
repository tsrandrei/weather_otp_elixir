defmodule MetexOtp.Worker do
  use GenServer

  # Client callbacks
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end
  # Client API
  def get_temperature(pid, location) do
    GenServer.call(pid, {:location, location})
  end

  def get_status(pid) do
    GenServer.call(pid, :get_status)
  end

  def reset_status(pid) do
    GenServer.cast(pid, :reset_status)
  end
  
  def kill(pid) do
    GenServer.cast(pid, :kill)
  end
  # Server callbacks
  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:location, location}, _from, current_status) do
    case temperature_of(location) do
      {:ok, temp} ->
        new_status = update_status(current_status, location)
        {:reply, "#{temp} C", new_status}
      _ ->
        {:reply, :error, current_status}
    end
  end

  def handle_call(:get_status, _from, status) do
    {:reply, status, status}
  end

  def handle_cast(:reset_status, _stats) do
    {:noreply, %{}}
  end

  def handle_cast(:kill, status) do
    {:stop, :normal, status}
  end

  def terminate(reason, status) do
    IO.puts "Server gracefully terminanted with following #{inspect reason}"
    inspect status
    :ok
  end

  # Helper functions
  defp temperature_of(location) do
    url_for(location)
    |> HTTPoison.get
    |> parse_response
  end

  defp url_for(location) do
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey()}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body
    |> JSON.decode!
    |> compute_temperature
  end

  defp parse_response(_) do
    :error
  end
  
  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15)
              |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  def apikey do
    Application.fetch_env!(:metex_otp, :open_weather_key)
  end

  defp update_status(old_status, location) do
    case Map.has_key?(old_status, location) do
      true ->
        Map.update!(old_status, location, &(&1+1))
      false ->
        Map.put_new(old_status, location, 1)
    end
  end
end
