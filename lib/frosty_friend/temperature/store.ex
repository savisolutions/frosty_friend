defmodule FrostyFriend.Temperature.Store do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(arg) do
    :ets.new(:temperatures, [
      :ordered_set,
      :public,
      :named_table
    ])

    {:ok, arg}
  end

  def list(%DateTime{} = date_time, measurement \\ "celsius", time_order \\ :asc) do
    date_comp = DateTime.to_unix(date_time)

    select_pattern =
      if measurement == "celsius" do
        [{{:"$1", :"$2", :_}, [{:>=, :"$1", date_comp}], [{{:"$1", :"$2"}}]}]
      else
        [{{:"$1", :_, :"$2"}, [{:>=, :"$1", date_comp}], [{{:"$1", :"$2"}}]}]
      end

    :temperatures
    |> :ets.select(select_pattern)
    |> Enum.map(fn {unix_date, temp} ->
      {DateTime.from_unix!(unix_date), temp}
    end)
    |> Enum.sort_by(&elem(&1, 0), time_order)
    |> Enum.map(fn {date, temp} -> %{date: date, temp: temp} end)
  end

  def put(temp_c, temp_v) do
    date_key = DateTime.to_unix(DateTime.utc_now())

    :ets.insert(:temperatures, {date_key, temp_c, temp_v})
  end
end
