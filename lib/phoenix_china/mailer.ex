defmodule PhoenixChina.Mailer do
  use Mailgun.Client,
    domain: Application.get_env(:phoenix_china, :mailgun_domain),
    key: Application.get_env(:phoenix_china, :mailgun_key)

  import Phoenix.View, only: [render_to_string: 3]
  alias PhoenixChina.PageView
  alias PhoenixChina.User

  @from "Phoenix中文社区 <mail@phoenix-china.org>"

  def send_confirmation_email(conn, user) do
    token = User.generate_token(user)
    text = render_to_string(PageView, "confirmation_email.txt", conn: conn, user: user, token: token)
    html = render_to_string(PageView, "confirmation_email.html", conn: conn, user: user, token: token)
    send_email to: user.email, from: @from, subject: "确认邮件", text: text, html: html
  end

  def send_reset_password_email(conn, user) do
    token = User.generate_token(user)
    text = render_to_string(PageView, "reset_password_email.txt", conn: conn, user: user, token: token)
    html = render_to_string(PageView, "reset_password_email.html", conn: conn, user: user, token: token)
    IO.inspect text
    IO.inspect html
    send_email to: user.email, from: @from, subject: "重置密码", text: text, html: html
  end
end
