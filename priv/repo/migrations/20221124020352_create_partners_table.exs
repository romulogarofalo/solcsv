defmodule Solcsv.Repo.Migrations.CreatePartnersTable do
  use Ecto.Migration

  def change do
    create table("partners") do
      add :cnpj, :string, [:primary_key]
      add :social_reason, :string
      add :fantasy_name, :string
      add :cellphone, :string
      add :email, :string
      add :cep, :string
      add :city, :string
      add :state, :string

      timestamps()
    end

    create unique_index(:partners, [:cnpj])
  end
end
