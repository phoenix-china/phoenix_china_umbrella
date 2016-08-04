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
alias PhoenixChina.User
import Ecto.Query

users = Repo.all(User)

Enum.map(users, fn user ->
  email = user.email
  |> String.trim
  |> String.downcase

  email_md5 = :crypto.hash(:md5, email)
  |> Base.encode16(case: :lower)

  avatar = "https://gravatar.tycdn.net/avatar/#{email_md5}?d=wavatar&s=#200"

  User
  |> where(id: ^user.id)
  |> update([u], set: [avatar: ^avatar])
  |> Repo.update_all([])
end)
