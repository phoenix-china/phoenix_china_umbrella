defmodule PhoenixChina.UserView do
  use PhoenixChina.Web, :view

  import PhoenixChina.ViewHelpers

  def tabs(conn, user) do
    [
      # {user_path(conn, :show, user.username), "index", "主页"},
      {user_path(conn, :show, user.username, tab: "post"), "post", "帖子"},
      {user_path(conn, :show, user.username, tab: "comment"), "comment", "回复"},
      {user_path(conn, :show, user.username, tab: "collect"), "collect", "收藏"},
      {user_path(conn, :show, user.username, tab: "followers"), "followers", "关注者"},
      {user_path(conn, :show, user.username, tab: "following"), "following", "正在关注"},
    ]
  end

  def subnavs(conn) do
    current_user = conn.assigns[:current_user]

    navigation = [
      {user_path(conn, :edit, "profile"), "profile", "个人信息"}
    ]

    case current_user.password_hash do
      nil -> navigation
      _ -> 
        navigation
        |> List.insert_at(1, {user_path(conn, :edit, "password"), "password", "修改密码"})
    end
  end
end
