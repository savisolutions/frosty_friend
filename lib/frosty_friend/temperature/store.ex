defmodule FrostyFriend.Temperature.Store do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(arg) do
    :ets.new(:temperatures, [
      :ordered_set,
      :public,
      :named_table
    ])

    {:ok, arg, {:continue, :schedule_delete}}
  end

  def handle_continue(:schedule_delete, state) do
    schedule_delete()

    {:noreply, state}
  end

  def handle_info(:delete_old_records, state) do
    delete_from = DateTime.add(DateTime.utc_now(), -4, :hour)
    Logger.debug("Deleting records older than #{delete_from}")
    delete(delete_from)

    schedule_delete()

    {:noreply, state}
  end

  def list(%DateTime{} = date_time, measurement \\ :celsius, time_order \\ :asc) do
    date_comp = DateTime.to_unix(date_time)

    select_pattern =
      if measurement == :celsius do
        [{{:"$1", :"$2", :_}, [{:>=, :"$1", date_comp}], [{{:"$1", :"$2"}}]}]
      else
        [{{:"$1", :_, :"$2"}, [{:>=, :"$1", date_comp}], [{{:"$1", :"$2"}}]}]
      end

    :temperatures
    |> :ets.select(select_pattern)
    |> Enum.map(fn {unix_date, temp} -> {DateTime.from_unix!(unix_date), temp} end)
    |> Enum.sort_by(&elem(&1, 0), time_order)
  end

  def put(temp_c, temp_v) do
    date_key = DateTime.to_unix(DateTime.utc_now())

    :ets.insert(:temperatures, {date_key, temp_c, temp_v})
  end

  def delete(%DateTime{} = date_time) do
    date_comp = DateTime.to_unix(date_time)
    :ets.select_delete(:temperatures, [{{:"$1", :_, :_}, [{:<, :"$1", date_comp}], [true]}])
  end

  defp schedule_delete do
    Process.send_after(self(), :delete_old_records, 30000)
  end
end
