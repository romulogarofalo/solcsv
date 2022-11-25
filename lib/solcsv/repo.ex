defmodule Solcsv.Repo do
  use Ecto.Repo,
    otp_app: :solcsv,
    adapter: Ecto.Adapters.Postgres
end
