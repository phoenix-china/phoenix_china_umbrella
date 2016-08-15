defmodule PhoenixChina.UserView do
  use PhoenixChina.Web, :view

  import PhoenixChina.ViewHelpers

  def subnavs(conn) do
    current_user = current_user(conn)

    navigation = [
      {:profile, "编辑个人信息", user_path(conn, :profile)}
    ]

    case current_user.password_hash do
      nil -> navigation
      _ -> List.insert_at(navigation, 1, {:account, "修改密码", user_path(conn, :account)})
    end

  end

end
