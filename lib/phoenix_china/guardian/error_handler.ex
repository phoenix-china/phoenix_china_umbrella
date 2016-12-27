defmodule PhoenixChina.Guardian.ErrorHandler do

  def unauthenticated(conn, _params) do
    conn
    |> Phoenix.Controller.put_flash(:error, "哎哟～ 不登录不能操作啊！")
    |> Phoenix.Controller.redirect(to: PhoenixChina.Router.Helpers.session_path(conn, :new))
  end
end