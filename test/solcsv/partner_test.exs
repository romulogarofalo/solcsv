defmodule Solcsv.PartnerTest do
	use ExUnit.Case
	doctest Solcsv.Partner
	alias Solcsv.Partner

  describe "changeset/2" do
		test "with ok params" do
			response = Partner.changeset(
				%Partner{},
				%{
					cnpj: "36.683.215/0001-00",
					social_reason: "123123123",
					fantasy_name: "123123123",
					cellphone: "11111111111",
					cep: "11111111",
					email: "123@123.com"
				}
			)

			assert response.valid? == true
			assert response.errors == []
			assert response.changes == %{
					cellphone: "11111111111",
					cep: "11111111",
					cnpj: "36.683.215/0001-00",
					email: "123@123.com",
					fantasy_name: "123123123",
					social_reason: "123123123"
				}
		end

		test "when params is not valid" do
			response = Partner.changeset(
				%Partner{},
				%{
					cellphone: "111111111211",
					cep: "111121111",
					cnpj: "36.683.215/0001-001",
					email: "123123.com",
					fantasy_name: "123123123",
					social_reason: "123123123"
				}
			)

			assert response.valid? == false
			assert response.errors == [
				email: {"has invalid format", [validation: :format]},
				cellphone: {"should be %{count} character(s)", [count: 11, validation: :length, kind: :is, type: :string]},
				cep: {"should be %{count} character(s)", [count: 8, validation: :length, kind: :is, type: :string]},
				cnpj: {"has invalid format", [validation: :format]}
			]
		end
  end

	describe "add_city_and_state/3" do
		test "with ok params aa" do
			response = Partner.changeset(
				%Partner{},
				%{
					cnpj: "36.683.215/0001-00",
					social_reason: "123123123",
					fantasy_name: "123123123",
					cellphone: "11111111111",
					cep: "11111111",
					email: "123@123.com"
				}
			)
			|> Partner.add_city_and_state("Santos", "SP")

			assert response.valid? == true
			assert response.errors == []
			assert response.changes == %{
				cellphone: "11111111111",
				cep: "11111111",
				city: "Santos",
				cnpj: "36.683.215/0001-00",
				email: "123@123.com",
				fantasy_name: "123123123",
				social_reason: "123123123",
				state: "SP"
			}
		end
	end
end
