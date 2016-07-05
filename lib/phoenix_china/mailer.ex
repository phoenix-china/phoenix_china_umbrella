defmodule PhoenixChina.Mailer do
  use Mailgun.Client,
    domain: Application.get_env(:phoenix_china, :mailgun_domain),
    key: Application.get_env(:phoenix_china, :mailgun_key)

  @from "Phoenix中文社区 <mail@phoenix-china.org>"

  def send_confirmation_email(user) do
     send_email to: user.email,
                from: @from,
                subject: "确认邮件",
                text: "确认邮件",
                html: "确认邮件"
  end

  def send_reset_password_email(user) do
    send_email to: user.email,
               from: @from,
               subject: "重置密码",
               text: "重置密码",
               html: "重置密码"
  end
end
