defmodule PhoenixChina.PageView do
  use PhoenixChina.Web, :view

  def navs(conn) do
    navigation = [
      {page_path(conn, :index), :index, "默认"},
      {page_path(conn, :last), :last, "最新"},
      {page_path(conn, :noreply), :noreply, "无人问津"},
    ]

     render("navs.html", conn: conn, navigation: navigation)
  end

  def is_today?(datetime) do
    datetime = PhoenixChina.ViewHelpers.strftime(datetime)
    today = PhoenixChina.ViewHelpers.strftime(Timex.today)
    datetime == today
  end
end
