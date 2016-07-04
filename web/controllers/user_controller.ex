defmodule PhoenixChina.UserController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.User
  plug PhoenixChina.GuardianPlug
  plug :put_layout, "user.html"

  def new(conn, _params) do
    changeset = User.changeset(:signup, %User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(:signup, %User{}, user_params)
    |> User.put_password_hash

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "注册成功了！.")
        |> redirect(to: session_path(conn, :new))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"nickname" => nickname}) do
    user = (from User, where: [nickname: ^nickname])
    |> first
    |> Repo.one!
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(:edit, user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end
end
