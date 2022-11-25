defmodule Solcsv.Ports.Viacep do
  alias Swoosh.Application
  alias Solcsv.Ports.Types.ViacepInput

  @callback check_cep(ViacepInput.t()) :: {:ok, any}

  @spec check_cep(ViacepInput.t()) :: {:ok, any()} | {:error, :not_found | :timeout | :bad_request}
  def check_cep(%ViacepInput{} = input) do
    adapter().check_cep(input)
  end

  defp adapter, do: :solcsv |> Application.fetch_env!(__MODULE__) |> Keyword.fetch!(:adapter)
end
