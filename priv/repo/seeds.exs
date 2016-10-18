# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PhoenixChina.Repo.insert!(%PhoenixChina.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PhoenixChina.{Repo, Post, Comment, PostLabel}
import PhoenixChina.Ecto.Helpers, only: [update_field: 3]
import Ecto.Query

labels = ["公告", "问题", "经验", "分享", "灌水", "招聘"]

Enum.map(Enum.with_index(labels), fn {name, index} ->
  label = PostLabel |> Repo.get_by(content: name)

  cond do
    is_nil(label) ->
      Repo.insert(%PostLabel{content: name, order: index})

    label.order != index and is_nil(label.is_hide) ->
      label |> update_field(:order, index) |> update_field(:is_hide, false)

    label.order != index ->
      label |> update_field(:order, index)

    is_nil(label.is_hide) ->
      label |> update_field(:is_hide, false)

    true -> ""
  end
end)

Enum.map(Repo.all(Post), fn post ->
  comments = Comment |> where(post_id: ^post.id) |> order_by([:inserted_at]) |> Repo.all

  Enum.map(comments |> Enum.with_index(1), fn {comment, index} ->
    comment |> update_field(:index, index)
  end)
end)
