defmodule Solcsv.Jobs.InsertCsvPartners do
  use Oban.Worker, queue: "default", max_attempts: 3
  require Logger

  alias Solcsv.Partner
  alias Solcsv.Ports.Viacep
  alias Solcsv.Ports.Types.ViacepInput

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
      changeset = Partner.create_changeset(
        %{
          cnpj: cnpj,
          email: email,
          social_reason: social_reason,
          fantasy_name: fantasy_name,
          cellphone: cellphone,
          cep: cep
        }
      )

      formated_cep = Ecto.Changeset.get_field(changeset, :cep) |> IO.inspect()

      {:ok, %{"localidade" => city, "uf" => state}} = Viacep.check_cep(%ViacepInput{cep: formated_cep}) |> IO.inspect()
      Partner.add_city_and_state(changeset, city, state)
      |> Solcsv.Repo.insert_or_update() # select antes para saber se tem que mandar email
      |> IO.inspect()

      File.rm!(path)
    end)

    :ok
  end
end
