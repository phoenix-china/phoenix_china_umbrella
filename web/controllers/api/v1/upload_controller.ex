defmodule PhoenixChina.API.V1.UploadController do
  use PhoenixChina.Web, :controller


  def create(conn, %{"file" => file}) do
    response = PhoenixChina.Qiniu.upload(file)

    case response do
      {:ok, upload} ->
        render conn, "show.json", upload: upload
      {:error, errors} ->
        conn
        |> put_status(:bad_request)
        |> json(errors)
    end
  end
end
