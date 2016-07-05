defmodule PhoenixChina.Mailer do
  use Mailgun.Client,
    domain: Application.get_env(:phoenix_china, :mailgun_domain),
    key: Application.get_env(:phoenix_china, :mailgun_key)

  import Phoenix.View, only: [render: 3]
  alias PhoenixChina.PageView

  @from "Phoenix中文社区 <mail@phoenix-china.org>"

  def send_confirmation_email(user) do
    text = render(PageView, "confirmation_email.txt", user: user)
    html = render(PageView, "confirmation_email.html", user: user)
    send_email to: user.email, from: @from, subject: "确认邮件", text: text, html: html
  end

  def send_reset_password_email(user) do
    text = render(PageView, "reset_password_email.txt", user: user)
    html = render(PageView, "reset_password_email.html", user: user)
    send_email to: user.email, from: @from, subject: "重置密码", text: text, html: html
  end
end
