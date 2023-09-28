defmodule FrostyFriendWeb.Charts do
  alias FrostyFriend.Temperature.Store
  use FrostyFriendWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    measurement = "celsius"
    time_span = 30
    temperature_data = get_temperature_data(time_span, measurement)

    form_params = %{"measurement" => measurement, "time_span" => time_span, "chart_type" => "line"}
    form = to_form(form_params)

    Process.send_after(self(), :update_data, 5000)

    chart_data = convert_to_chart_data(temperature_data)

    {:ok, assign(socket, chart_data: chart_data, form: form)}
  end

  @impl true
  def handle_info(:update_data, socket) do
    time_span = socket.assigns.form.params["time_span"]
    measurement = socket.assigns.form.params["measurement"]
    temperature_data = get_temperature_data(time_span, measurement)
    chart_data = convert_to_chart_data(temperature_data)
    Process.send_after(self(), :update_data, 5000)

    {:noreply, push_event(socket, "update-points", chart_data)}
  end

  @impl true
  def handle_event("apply_params", %{"options" => params}, socket) do
    measurement = Map.get(params, "measurement", "celsius")
    time_span = Map.get(params, "time_span", "30") |> String.to_integer()
    chart_type = Map.get(params, "chart_type", "line")

    form_params = %{"measurement" => measurement, "time_span" => time_span, "chart_type" => chart_type}
    form = to_form(form_params)

    temperature_data = get_temperature_data(time_span, measurement)
    chart_data = convert_to_chart_data(temperature_data)
    push_event(socket, "update-type", %{type: chart_type})
    {:noreply, assign(socket, chart_data: chart_data, form: form)}
  end

  def get_temperature_data(time_span, measurement) do
    target_time = DateTime.utc_now() |> DateTime.add(-time_span, :second)
    Store.list(target_time, measurement)
  end

  defp convert_to_chart_data(temperature_data) do
    %{
      labels: Enum.map(temperature_data, &Map.get(&1, :date)),
      data: Enum.map(temperature_data, &Map.get(&1, :temp))
    }
  end
end
