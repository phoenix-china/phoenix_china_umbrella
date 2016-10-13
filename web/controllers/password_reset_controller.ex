defmodule PhoenixChina.PasswordResetController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.User
  import Phoenix.View, only: [render_to_string: 3]

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(:password_reset_for_email, %User{}, user_params)

    case changeset.valid? do
      true ->
        user = changeset.data
        token = User.generate_token(user)

        html = render_to_string(
          PhoenixChina.PasswordResetView,
          "password-reset.html",
          conn: conn,
          user: user,
          token: token
        )

        text = render_to_string(
          PhoenixChina.PasswordResetView,
          "password-reset.txt",
          conn: conn,
          user: user,
          token: token
        )

        AliyunDirectMail.Mail.single_send(
          account_name: "noreply@mail.phoenix-china.org",
          from_alias: "PhoenixChina",
          to_address: user.email,
          subject: "[PhoenixChina]请重置您的密码",
          html_body: html,
          text_body: text
        )

        conn
        |> assign(:title, "找回密码")
        |> render("show-for-success.html")

      false ->
        changeset = %{changeset | action: :password_reset}
        conn
        |> assign(:title, "找回密码")
        |> assign(:changeset, changeset)
        |> render("show-for-email.html")
    end
  end

  def show(conn, %{"token" => token}) do
    case User.validate_token(token) do
      {:ok, user_id} ->
        user = Repo.get!(User, user_id)
        changeset = User.changeset(:password_reset, user)

        conn
        |> assign(:title, "重置密码")
        |> assign(:token, token)
        |> assign(:user, user)
        |> assign(:changeset, changeset)
        |> render("show.html")
      {:error, :invalid} ->
        conn
        |> put_flash(:error, "重置密码链接不正确")
        |> redirect(to: password_reset_path(conn, :show))
      {:error, :expired} ->
        conn
        |> put_flash(:error, "重置密码链接已过期")
        |> redirect(to: password_reset_path(conn, :show))
    end
  end

  def show(conn, _params) do
    changeset = User.changeset(:password_reset_for_email, %User{})

    conn
    |> assign(:title, "找回密码")
    |> assign(:changeset, changeset)
    |> render("show-for-email.html")
  end

  def update(conn, %{"token" => token, "user" => user_params}) do
    case User.validate_token(token) do
      {:ok, user_id} ->
        user = Repo.get!(User, user_id)
        changeset = User.changeset(:password_reset, user, user_params)

        case Repo.update(changeset) do
          {:ok, _user} ->
            conn
            |> put_flash(:info, "重置密码成功，请登录。")
            |> redirect(to: session_path(conn, :new))
          {:error, changeset} ->
            conn
            |> assign(:title, "重置密码")
            |> assign(:token, token)
            |> assign(:user, user)
            |> assign(:changeset, changeset)
            |> render("show.html")
        end
      {:error, :invalid} ->
        conn
        |> put_flash(:error, "重置密码链接不正确")
        |> redirect(to: password_reset_path(conn, :show))
      {:error, :expired} ->
        conn
        |> put_flash(:error, "重置密码链接已过期")
        |> redirect(to: password_reset_path(conn, :show))
    end
  end
end
