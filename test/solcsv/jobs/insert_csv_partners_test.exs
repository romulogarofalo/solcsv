defmodule Solcsv.Jobs.InsertCsvPartnersTest do
  use Solcsv.DataCase
  use Oban.Testing, repo: Solcsv.Repo

  import ExUnit.CaptureLog
  import Hammox

	alias Solcsv.Jobs.InsertCsvPartners
  alias Solcsv.Partner
  alias SolcsvAdapters.ViacepAdapterMock

  describe "perform/1" do
    test "with no register in database, should insert new one and send email" do
      dir = System.tmp_dir!()
      final_path = Path.join(dir, "#{Ecto.UUID.generate}.csv")

      File.copy("priv/static/test.csv", final_path)

      expect(ViacepAdapterMock, :check_cep, fn _env ->
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

      assert [] == Repo.all(Partner)

      assert capture_log(
        fn -> perform_job(InsertCsvPartners, %{"path" => final_path})
      end) =~ "[error] Elixir.Solcsv.Jobs.InsertCsvPartners error: invalid_changeset"

      assert [updated_partner] = Repo.all(Partner)

      assert updated_partner.email == "atendimento@soleterno.com"
      assert updated_partner.social_reason == "Sol Eterno2"
      assert updated_partner.fantasy_name == "Sol Eterno LTDA"
      assert updated_partner.cellphone == "21982079901"
      assert updated_partner.cep == "22783115"
      assert updated_partner.city == "Santos"
      assert updated_partner.state == "SP"
    end

    test "update register on database" do
      dir = System.tmp_dir!()
      final_path = Path.join(dir, "#{Ecto.UUID.generate}.csv")

      File.copy("priv/static/test.csv", final_path)

      %{
        id: id,
        cnpj: cnpj
      } = Partner.changeset(
        %Partner{},
        %{
          cnpj: "16.470.954/0001-06",
          social_reason: "123123123",
          fantasy_name: "123123123",
          cellphone: "11111111111",
          cep: "11111111",
          email: "123@123.com"
			  }
      )
      |> Partner.add_city_and_state("Santos", "SP")
      |> Repo.insert!()

      expect(ViacepAdapterMock, :check_cep, fn _env ->
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

      assert capture_log(
        fn -> perform_job(InsertCsvPartners, %{"path" => final_path})
      end) =~ "[error] Elixir.Solcsv.Jobs.InsertCsvPartners error: invalid_changeset"

      assert [updated_partner] = Repo.all(Partner)

      assert updated_partner.id == id
      assert updated_partner.cnpj == cnpj
      assert updated_partner.email == "atendimento@soleterno.com"
      assert updated_partner.social_reason == "Sol Eterno2"
      assert updated_partner.fantasy_name == "Sol Eterno LTDA"
      assert updated_partner.cellphone == "21982079901"
      assert updated_partner.cep == "22783115"
      assert updated_partner.city == "Santos"
      assert updated_partner.state == "SP"
    end

    test "when request to viacep fail" do
      dir = System.tmp_dir!()
      final_path = Path.join(dir, "#{Ecto.UUID.generate}.csv")

      File.copy("priv/static/test.csv", final_path)

      Partner.changeset(
        %Partner{},
        %{
          cnpj: "16.470.954/0001-06",
          social_reason: "123123123",
          fantasy_name: "123123123",
          cellphone: "11111111111",
          cep: "11111111",
          email: "123@123.com"
			  }
      )
      |> Partner.add_city_and_state("Santos", "SP")
      |> Repo.insert!()

      expect(ViacepAdapterMock, :check_cep, 5, fn _env ->
        {:error, :bad_request}
      end)


      assert capture_log(
        fn -> perform_job(InsertCsvPartners, %{"path" => final_path})
      end) =~ "[error] Elixir.Solcsv.Jobs.InsertCsvPartners error: bad_request"
    end
  end
end
