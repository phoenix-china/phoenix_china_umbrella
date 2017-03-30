defmodule PhoenixChina.Emails do
  use Bamboo.Phoenix, view: PhoenixChina.Web.EmailView

  alias PhoenixChina.Mailer

  @from "Support<support@mg.phoenix-china.org>"

  @doc """
  欢迎邮件
  """
  def welcome_email(person) do
      base_email()
      |> to(person)
      |> subject("欢迎注册Phoenix中文社区")
      |> render(:welcome)
      |> send
  end

  defp base_email do
    new_email()
    |> from(@from)
    |> put_html_layout({PhoenixChina.Web.LayoutView, "email.html"})
  end

  defp send(mail) do
    if System.get_env("MAILGUN_API_KEY") && System.get_env("MAILGUN_DOMAIN") do
      Mailer.deliver_later(mail)
    end
  end
end