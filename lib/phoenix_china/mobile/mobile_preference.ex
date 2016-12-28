defmodule PhoenixChina.MobilePreferenceController do
  use PhoenixChina.Web, :controller

  def create(conn, %{"mobile" => is_mobile}) do
    redirect_to = get_req_header(conn, "referer") |> List.first

    conn
    |> put_session(:mobile, is_mobile)
    |> redirect(external: redirect_to)
  end
end