defmodule SolcsvAdapters.ViacepAdapter do
  alias Solcsv.Ports.Types.ViacepInput
  @behaviour Solcsv.Ports.Viacep

  @impl true
  def check_cep(%ViacepInput{cep: cep}) do
    query = "#{cep}/json/"

    client()
    |> Tesla.get(query)
    |> case do
      {:ok, %{body: %{"error" => true}, status: 200}} ->
        {:error, :not_found}
      {:ok, %{body: body, status: 200}} ->
        {:ok, body}
      {:ok, %{status: 400}} ->
        {:error, :bad_request}
      result ->
        result
    end
  end

  defp client() do
    middleware = [
      Tesla.Middleware.JSON,
      Tesla.Middleware.PathParams,
      {Tesla.Middleware.BaseUrl, base_url()},
      {Tesla.Middleware.Timeout, timeout: timeout()},
      {Tesla.Middleware.Opts, [adapter: [recv_timeout: timeout()]]}
    ]

    adapter = {Application.fetch_env!(:tesla, :adapter), [pool: :viacep]}
    Tesla.client(middleware, adapter)
  end

  defp base_url, do: module_config(:base_url)
  defp timeout, do: module_config(:timeout)

  defp module_config(name) do
    :solcsv
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.fetch!(name)
  end
end
