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

alias PhoenixChina.Repo
alias PhoenixChina.PostLabel


labels = ["问题", "经验", "分享", "灌水", "招聘"]

Enum.map(labels, fn label ->
  case PostLabel |> Repo.get_by(content: label) do
    nil -> Repo.insert(%PostLabel{content: label})
    _ -> ""
  end
end)
