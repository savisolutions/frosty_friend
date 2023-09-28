defmodule FrostyFriendWeb.Charts do
  alias FrostyFriend.Temperature.Store
  use FrostyFriendWeb, :live_view

  @spec mount(any, any, atom | %{:assigns => map, optional(any) => any}) :: {:ok, any}
  def mount(_params, _session, socket) do
    temperature_data = get_temperature_data()

    Process.send_after(self(), :update_data, 5000)

    chart_data = convert_to_chart_data(temperature_data)

    {:ok, assign(socket, chart_data: chart_data)}
  end

  def handle_info(:update_data, socket) do
    temperature_data = get_temperature_data()
    chart_data = convert_to_chart_data(temperature_data)
    Process.send_after(self(), :update_data, 5000)

    {:noreply,
     socket
     |> push_event("update-points", chart_data)}
  end

  def get_temperature_data do
    utc_now = DateTime.utc_now() |> DateTime.add(-1, :minute)
    Store.list(utc_now, :celsius, :desc)
  end

  defp convert_to_chart_data(temperature_data) do
    %{
      labels: Enum.map(temperature_data, &Map.get(&1, :date)),
      data: Enum.map(temperature_data, &Map.get(&1, :temp))
    }
  end
end
