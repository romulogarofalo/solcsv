defmodule SolcsvWeb.PartnerController do
  use SolcsvWeb, :controller

  alias Solcsv.Jobs.InsertCsvPartners

  def upload(conn, %{"file" => file}) do
    final_path = "priv/static/#{Ecto.UUID.generate}.csv"

    with {:ok, _} <- File.copy(file.path, final_path),
      {:ok, job} <- create_job(final_path),
      {:ok, _} <- Oban.insert(job) do
        json(conn, %{"message" => "upload sucesseful?"})
      else
        {:error, :invalid_content} -> json(conn, %{"message" => "upload fail"}) # tem haver com o cliente um 400?
        {:error, %Oban.Job{}} -> json(conn, %{"message" => "create job fail"}) #should be 500 nada haver com o cliente
        {:error, _} -> json(conn, %{"message" => "read file fail"})
    end
  end

  defp create_job(final_path) do
    %{valid?: valid} = job = InsertCsvPartners.new(%{"path" => final_path})
    if valid do
      {:ok, job}
    else
      {:error, :invalid_content}
    end
  end
end
