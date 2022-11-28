defmodule SolcsvAdapters.ViacepAdapterTest do
  use ExUnit.Case
  import Hammox

  alias SolcsvAdapters.ViacepAdapter
  alias Solcsv.Ports.Types.ViacepInput

  describe "check_cep/1" do
    test "when return all addres" do
      response_body = %{
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
      }

      expect(TeslaMock, :call, fn %Tesla.Env{
        method: :get,
        url: url,
        headers: headers,
        opts: opts
      } = env, _ ->
        assert opts == [adapter: [recv_timeout: 10_000]]
        assert url == "testurl/11050100/json/"
        assert headers == []

        {:ok, %Tesla.Env{env | status: 200, body: response_body}}
      end)

      assert {:ok, %{
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
      }} == ViacepAdapter.check_cep(%ViacepInput{cep: "11050100"})
    end

    test "when timeout response, should return :timeout" do
      expect(TeslaMock, :call, fn %Tesla.Env{
        method: :get,
        url: url,
        headers: headers,
        opts: opts
      } = env, _ ->
        assert opts == [adapter: [recv_timeout: 10_000]]
        assert url == "testurl/11050100/json/"
        assert headers == []

        {:ok, %Tesla.Env{env | status: 408}}
      end)

      assert {:error, :timeout} == ViacepAdapter.check_cep(%ViacepInput{cep: "11050100"})
    end

    test "when don't find cep, should return :not_found" do
      expect(TeslaMock, :call, fn %Tesla.Env{
        method: :get,
        url: url,
        headers: headers,
        opts: opts
      } = env, _ ->
        assert opts == [adapter: [recv_timeout: 10_000]]
        assert url == "testurl/11050100/json/"
        assert headers == []

        {:ok, %Tesla.Env{env | body: %{"error" => true}, status: 200}}
      end)

      assert {:error, :not_found} == ViacepAdapter.check_cep(%ViacepInput{cep: "11050100"})
    end

    test "when make a request with wrong url, should return :bad_request" do
      expect(TeslaMock, :call, fn %Tesla.Env{
        method: :get,
        url: url,
        headers: headers,
        opts: opts
      } = env, _ ->
        assert opts == [adapter: [recv_timeout: 10_000]]
        assert url == "testurl/11050100/json/"
        assert headers == []

        {:ok, %Tesla.Env{env | status: 400}}
      end)

      assert {:error, :bad_request} == ViacepAdapter.check_cep(%ViacepInput{cep: "11050100"})
    end
  end
end
