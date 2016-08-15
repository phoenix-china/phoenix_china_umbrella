defmodule PhoenixChina.PageView do
  use PhoenixChina.Web, :view

  def navs(conn, labels) do
     navigation = Enum.map(labels, fn label ->
       [page_path(conn, :index, label: label.content), label.content, label.content]
     end)
     |> List.insert_at(0, ["/", "全部", "全部"])

     render("navs.html", conn: conn, navigation: navigation)
  end
end
