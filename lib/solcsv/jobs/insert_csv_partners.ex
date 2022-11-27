defmodule Solcsv.Jobs.InsertCsvPartners do
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
    |> Enum.map(fn [cnpj, social_reason, fantasy_name, cellphone, email, cep] ->
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

      formated_cep = Ecto.Changeset.get_field(changeset, :cep)
      {:ok, %{"localidade" => city, "uf" => state}} = Viacep.check_cep(%ViacepInput{cep: formated_cep})

      Partner.add_city_and_state(changeset, city, state)
      |> Repo.insert_or_update()

      send_email(changeset)

      File.rm!(path)
    end)

    :ok
  end

  defp build_changeset_parnter(nil), do: %Partner{}
  defp build_changeset_parnter(partner), do: partner

  defp send_email(%Ecto.Changeset{data: %{__meta__: %{state: :built}}}), do: Logger.info("email sent")
  defp send_email(_), do: nil
end
