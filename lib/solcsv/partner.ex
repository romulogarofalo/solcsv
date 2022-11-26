defmodule Solcsv.Partner do
  use Ecto.Schema
  import Ecto.Changeset

  schema "partners" do
    field :cnpj
    field :email
    field :social_reason
    field :fantasy_name
    field :cellphone
    field :cep
    field :city
    field :state

    timestamps()
  end

  def create_changeset(params \\ %{}) do
    cast(%__MODULE__{}, params, [:cnpj, :social_reason, :fantasy_name, :cellphone, :email, :cep])
    |> validate_required([:cnpj, :social_reason, :fantasy_name, :cellphone, :email, :cep])
    |> validate_format(:cnpj, ~r/^\d{2}\.\d{3}\.\d{3}\/\d{4}\-\d{2}$/)
    |> format_fields(:cep)
    |> format_fields(:cellphone)
    |> validate_length(:cep, is: 8)
    |> validate_length(:cellphone, is: 11)
    |> validate_format(:email, ~r/^[a-zA-Z0-9]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/)
    |> unique_constraint([:cnpj])
  end

  defp format_fields(changeset, field) do
    field_clear = changeset
    |> get_field(field)
    |> take_off_dots_and_traces()

    put_change(changeset, field, field_clear)
  end

  defp take_off_dots_and_traces(input) do
    input
    |> String.codepoints()
    |> Enum.filter(fn x ->
      !(x == "-" or x == ")" or x == "(" or x == " ")
    end)
    |> Enum.join()
  end

  def add_city_and_state(changeset, city, state) do
    cast(changeset, %{city: city, state: state}, [:city, :state])
  end
end
