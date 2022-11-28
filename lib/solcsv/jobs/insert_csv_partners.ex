defmodule Solcsv.Jobs.InsertCsvPartners do
  @moduledoc """
  job to parse the csv validate the data to insert or update
  a partner on database
  """

  use Oban.Worker, queue: "default", max_attempts: 3
  require Logger

  alias Solcsv.Partner
  alias Solcsv.Ports.Viacep
  alias Solcsv.Ports.Types.ViacepInput
  alias Solcsv.Repo

  alias NimbleCSV.RFC4180, as: CSV

  @impl Oban.Worker
  def perform(%Oban.Job{
    args: %{
      "path" => path
    }
  }) do
    File.stream!(path)
    |> CSV.parse_stream()
    |> Enum.each(fn [cnpj, social_reason, fantasy_name, cellphone, email, cep] ->
      changeset = Partner
      |> Repo.get_by(cnpj: cnpj)
      |> build_changeset_parnter()
      |> Partner.changeset(
        %{
          cnpj: cnpj,
          email: email,
          social_reason: social_reason,
          fantasy_name: fantasy_name,
          cellphone: cellphone,
          cep: cep
        }
      )

      with {:ok, cep} <- get_cep_changeset(changeset),
      {:ok, %{"localidade" => city, "uf" => state}} <- Viacep.check_cep(%ViacepInput{cep: cep}),
      changeset_to_insert <- Partner.add_city_and_state(changeset, city, state),
      {:ok, _} <- Repo.insert_or_update(changeset_to_insert) do
        send_email(changeset)
        File.rm(path)
      else
        {:error, :invalid_changeset} -> Logger.error("#{__MODULE__} error: invalid_changeset, changeset: #{inspect(changeset)}")
        {:error, :not_found} -> Logger.error("#{__MODULE__} error: not_found")
        {:error, :timeout} -> Logger.error("#{__MODULE__} error: timeout")
        {:error, :bad_request} -> Logger.error("#{__MODULE__} error: bad_request")
        error -> Logger.error("#{__MODULE__} error: #{inspect(error)}")
      end
    end)
    :ok
  end

  defp get_cep_changeset(%{valid?: false}), do: {:error, :invalid_changeset}
  defp get_cep_changeset(%{valid?: true} = changeset) do
    {:ok, Ecto.Changeset.get_field(changeset, :cep)}
  end

  defp build_changeset_parnter(nil), do: %Partner{}
  defp build_changeset_parnter(partner), do: partner

  defp send_email(%Ecto.Changeset{data: %{__meta__: %{state: :built}}}), do: Logger.info("email sent")
  defp send_email(_), do: nil
end
