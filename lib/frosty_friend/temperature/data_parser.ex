defmodule FrostyFriend.Temperature.DataParser do

  @spec parse(String.t()) :: {:ok, float(), float()} | {:error, :invalid_temperature_data | :temperature_not_found}
  def parse(data) do
    with {:ok, valid_line} <- get_valid_line(data),
         {:ok, string_temperature} <- parse_temperature_from_line(valid_line),
         {:ok, float_temp_c} <- convert_to_float(string_temperature) do
      {:ok, float_temp_c, convert_to_fahrenheit(float_temp_c)}
    end
  end

  defp get_valid_line(data) do
    case String.split(data, "\n") do
      [_, line2 | _] -> {:ok, line2}
      _ -> {:error, :invalid_temperature_data}
    end
  end

  defp parse_temperature_from_line(line) do
    line
    |> String.split(" ")
    |> List.last()
    |> then(&Regex.named_captures(~r/.*t=(?<temp>.*)/, &1))
    |> case do
      %{"temp" => temp} -> {:ok, temp}
      _ -> {:error, :temperature_not_found}
    end
  end

  defp convert_to_float(temp) do
    case Float.parse(temp) do
      {float_temp, ""} -> {:ok, float_temp / 1000.0}
      _ -> {:error, :invalid_temperature_data}
    end
  end

  defp convert_to_fahrenheit(float_temp_c) do
    float_temp_c * 9.0 / 5.0 + 32.0
  end
end
