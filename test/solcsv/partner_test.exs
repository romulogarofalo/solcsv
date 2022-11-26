defmodule Solcsv.PartnerTest do
	use ExUnit.Case
	doctest Solcsv.Partner
	alias Solcsv.Partner

  describe "changeset/2" do
		test "with ok params" do
			Partner.create_changeset(%{
				cnpj: "36.683.215/0001-00",
				social_reason: "123123123",
				fantasy_name: "123123123",
				cellphone: "123123123",
				cep: "123123132",
				email: "123@123.com"
				})
		end
  end

	describe "add_city_and_state/3" do
		test "with ok params aa" do
			partner = Partner.create_changeset(%{
				cnpj: "36.683.215/0001-00",
				social_reason: "123123123",
				fantasy_name: "123123123",
				cellphone: "123123123",
				cep: "11060481",
				email: "123123.com"
			})
			|> Ecto.Changeset.get_change(:cep)
			|> IO.inspect(label: "cep")

			# cep = Partner.add_city_and_state(partner, "santos", "sao paulo")
		end
	end

end
