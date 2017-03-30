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
    |> Mailer.deliver_later
  end

  defp base_email do
    new_email()
    |> from(@from)
    |> put_html_layout({PhoenixChina.Web.LayoutView, "email.html"})
  end
end