defmodule PhoenixChina.UserView do
  use PhoenixChina.Web, :view
  
  def subnavs(conn) do
    [
      {:profile, "编辑个人信息", user_path(conn, :profile)},
      {:account, "修改密码", user_path(conn, :account)},
    ]
  end

end
