defmodule FrostyFriendWeb.Charts do
  alias FrostyFriend.Temperature.Store
  use FrostyFriendWeb, :live_view

  @spec mount(any, any, atom | %{:assigns => map, optional(any) => any}) :: {:ok, any}
  def mount(_params, _session, socket) do
    temp_data = Map.get(socket.assigns, :temperature_data, [])
    temperature_data = get_temperature_data(temp_data)

    Process.send_after(self(), :update_data, 5000)

    {:ok, assign(socket, temperature_data: temperature_data)}
  end

  def handle_info(:update_data, socket) do
    temperature_data = get_temperature_data(socket.assigns.temperature_data)
    Process.send_after(self(), :update_data, 5000)

    {:noreply, assign(socket, temperature_data: temperature_data)}
  end

  def get_temperature_data(_temperature_data) do
    utc_now = DateTime.utc_now() |> DateTime.add(-1, :minute)
    Store.list(utc_now, :celsius, :desc)
  end
end
