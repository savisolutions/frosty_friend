defmodule FrostyFriend.Temperature.Probe do
  use GenServer
  require Logger

  alias FrostyFriend.Temperature.DataParser
  alias FrostyFriend.Temperature.Store

  @base_file_path "/sys/bus/w1/devices/"
  @device_file_name "/w1_slave"
  @poll_interval :timer.seconds(5)

  def start_link(device_id) do
    with {:ok, device_path} <- device_path(device_id) do
      GenServer.start_link(__MODULE__, %{device_path: device_path}, name: __MODULE__)
    end
  end

  def start_link() do
    {:error, :device_id_required}
  end

  @impl true
  def init(state) do
    {:ok, {:continue, :schedule, state}}
  end

  @impl true
  def handle_continue(:schedule, state) do
    schedule()
    {:noreply, state}
  end

  @impl true
  def handle_call(:poll, _caller, %{device_path: device_path} = state) do
    spawn_port(device_path)

    {:reply, :ok, state}
  end

  def handle_call({:poll, device_path_override}, _caller, state) do
    spawn_port(device_path_override)

    {:reply, :ok, state}
  end

  @impl true
  def handle_info(:poll, %{device_path: device_path} = state) do
    spawn_port(device_path)
    schedule()

    {:noreply, state}
  end

  def handle_info({:EXIT, _port, reason}, state) do
    Logger.debug("Port closed: #{reason}")
    {:noreply, state}
  end

  def handle_info({port, {:data, msg}}, state) do
    Logger.debug("Received message from port")

    case DataParser.parse(msg) do
      {:ok, temp_c, temp_f} ->
        Store.put(temp_c, temp_f)

      error ->
        Logger.error(error)
    end

    close_port(port)
    {:noreply, state}
  end

  def call_temp do
    GenServer.call(__MODULE__, :poll)
  end

  def call_temp(device_path_override) do
    GenServer.call(__MODULE__, {:poll, device_path_override})
  end

  defp schedule do
    Process.send_after(self(), :poll, @poll_interval)
  end

  defp spawn_port(device_path) do
    path = System.find_executable("cat")
    Port.open({:spawn_executable, path}, [:binary, args: [device_path]])
  end

  defp close_port(port) do
    if Port.info(port) != nil do
      Port.close(port)
    end
  end

  defp device_path(device_id) when is_binary(device_id) do
    {:ok, @base_file_path <> device_id <> @device_file_name}
  end

  defp device_path(_), do: {:error, :invalid_device_id}
end
