defmodule PhoenixChina.MobilePreferenceController do
  use PhoenixChina.Web, :controller

  def create(conn, %{"mobile" => is_mobile}) do
    referer = 
      conn
      |> get_req_header("referer") 
      |> hd

    conn
    |> put_session(:mobile, is_mobile)
    |> redirect(external: referer)
  end
end