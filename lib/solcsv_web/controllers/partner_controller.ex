defmodule SolcsvWeb.PartnerController do
  use SolcsvWeb, :controller

  alias Solcsv.Jobs.InsertCsvPartners

  def upload(conn, %{"file" => file}) do
    dir = System.tmp_dir!()
    final_path = Path.join(dir, "#{Ecto.UUID.generate}.csv")

    with {:ok, _} <- copy_file(file, final_path),
      {:ok, job} <- create_job(final_path),
      {:ok, _} <- Oban.insert(job) do
        send_resp(conn, 200, "{\"message\":\"upload sucesseful\"}")
      else
        {:error, :invalid_content} -> send_resp(conn, 400, "{\"message\":\"upload fail\"}")
        {:error, %Oban.Job{}} -> send_resp(conn, 500, "{\"message\":\"create job fail\"}")
        {:error, _} -> send_resp(conn, 400, "{\"message\":\"read file fail\"}")
    end
  end

  defp copy_file(%{path: path}, final_path), do: File.copy(path, final_path)
  defp copy_file(_, _), do: {:error, :invalid_content}

  defp create_job(final_path) do
    %{valid?: valid} = job = InsertCsvPartners.new(%{"path" => final_path})
    if valid do
      {:ok, job}
    else
      {:error, :invalid_content}
    end
  end
end
