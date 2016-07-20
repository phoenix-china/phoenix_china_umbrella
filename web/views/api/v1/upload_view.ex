defmodule PhoenixChina.API.V1.UploadView do
  use PhoenixChina.Web, :view

  def render("show.json", %{upload: upload}) do
    %{data: render_one(upload, PhoenixChina.API.V1.UploadView, "upload.json")}
  end

  def render("upload.json", %{upload: upload}) do
    %{
      hash: upload.hash,
      key: upload.key,
      url: upload.url
    }
  end
end
