defmodule SolcsvWeb.PartnerControllerTest do
  use SolcsvWeb.ConnCase
  use Oban.Testing, repo: Solcsv.Repo

  import ExUnit.CaptureLog
  import Hammox
  alias SolcsvAdapters.ViacepAdapterMock

  describe "/upload/csv" do
    test "upload csv", %{conn: conn} do
      upload = %Plug.Upload{path: "priv/static/test.csv", filename: "test.csv"}

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

      assert capture_log(fn ->
        conn = post(conn, Routes.partner_path(conn, :upload), %{"file" => upload})
        assert conn.status == 200
        assert conn.resp_body == "{\"message\":\"upload sucesseful\"}"
      end) =~ "[error] Elixir.Solcsv.Jobs.InsertCsvPartners error: invalid_changeset"

      [updated_partner] = Solcsv.Repo.all(Solcsv.Partner)

      assert updated_partner.email == "atendimento@soleterno.com"
      assert updated_partner.social_reason == "Sol Eterno2"
      assert updated_partner.fantasy_name == "Sol Eterno LTDA"
      assert updated_partner.cellphone == "21982079901"
      assert updated_partner.cep == "22783115"
      assert updated_partner.city == "Santos"
      assert updated_partner.state == "SP"
    end

    test "upload csv with no input, should return upload fail", %{conn: conn} do
      conn = post(conn, Routes.partner_path(conn, :upload), %{"file" => ""})

      assert conn.status == 400
      assert conn.resp_body == "{\"message\":\"upload fail\"}"
    end

    test "upload csv with no exist file, should return read file fail", %{conn: conn} do
      upload = %Plug.Upload{path: "priv/static/aaaa", filename: "aaaa"}
      conn = post(conn, Routes.partner_path(conn, :upload), %{"file" => upload})

      assert conn.status == 400
      assert conn.resp_body == "{\"message\":\"read file fail\"}"
    end
  end
end
