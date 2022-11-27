defmodule Solcsv.Jobs.InsertCsvPartnersTest do
  use Solcsv.DataCase
  use Oban.Testing, repo: Solcsv.Repo

  import Hammox

	alias Solcsv.Jobs.InsertCsvPartners
  alias Solcsv.Partner
  alias Solcsv.Ports.Viacep
  alias Solcsv.Ports.Types.ViacepInput
  alias SolcsvAdapters.ViacepAdapterMock

  describe "perform/1" do
    # test "with no register in database, should insert new one and send email" do

    # end

    test "update register on database" do
      final_path = "priv/static/#{Ecto.UUID.generate}.csv"
      {:ok, _} <- File.copy("priv/static/test.csv", final_path),

      Partner.create_changeset(%{
				cnpj: "16.470.954/0001-06",
				social_reason: "123123123",
				fantasy_name: "123123123",
				cellphone: "11111111111",
				cep: "11111111",
				email: "123@123.com"
			})
      |> Partner.add_city_and_state("Santos", "SP")
      |> Repo.insert!()

      expect(ViacepAdapterMock, :check_cep, 5, fn _env ->
        {:ok, %{
          "cep" => "11050-100",
          "logradouro" => "Rua Goiás",
          "complemento" => "até 121/122",
          "bairro" => "Boqueirão",
          "localidade" => "Santos",
          "uf" => "SP",
          "ibge" => "3548500",
          "gia" => "6336",
          "ddd" => "13",
          "siafi" => "7071"
        }}
      end)

      perform_job(InsertCsvPartners, %{"path" => final_path})

      Repo.all(Partner) |> IO.inspect()

    end
  end
end
