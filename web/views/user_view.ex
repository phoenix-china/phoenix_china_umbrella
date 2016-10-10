defmodule PhoenixChina.UserView do
  use PhoenixChina.Web, :view

  import PhoenixChina.ViewHelpers

  def tabs(conn, user) do
    [
      # {"index", "主页", user_path(conn, :show, user.username)},
      {"post", "帖子", user_path(conn, :show, user.username, tab: "post")},
      {"comment", "回复", user_path(conn, :show, user.username, tab: "comment")},
      {"collect", "收藏", user_path(conn, :show, user.username, tab: "collect")},
      {"followers", "关注者", user_path(conn, :show, user.username, tab: "followers")},
      {"following", "正在关注", user_path(conn, :show, user.username, tab: "following")},
    ]
  end

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
