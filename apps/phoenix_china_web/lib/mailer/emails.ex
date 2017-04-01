defmodule PhoenixChina.Emails do
  use Bamboo.Phoenix, view: PhoenixChina.Web.EmailView

  alias PhoenixChina.Mailer
  alias PhoenixChina.Models.User
  alias PhoenixChina.UserContext

  @from "Phoenix中文社区<support@mg.phoenix-china.org>"

  defmacro send(mail) do
    if System.get_env("MAILGUN_API_KEY") && System.get_env("MAILGUN_DOMAIN") do
      quote do
        Mailer.deliver_later(unquote(mail))
      end
    else
      quote do
        IO.puts("环境变量 MAILGUN_API_KEY 和 MAILGUN_DOMAIN 未设置，不能给 #{unquote(mail).to} 正常发送邮件。")
      end
    end
  end

  @doc """
  欢迎邮件
  """
  def welcome_email(person) do
    email = 
      base_email()
      |> to(person)
      |> subject("欢迎注册Phoenix中文社区")
      |> render(:welcome)
    
    send(email)
  end

  @doc """
  找回密码邮件
  """
  def password_reset_email(%User{} = user) do
    email = 
      base_email()
      |> to(user.email)
      |> subject("找回您的账号密码")
      |> assign(:user, user)
      |> assign(:token, UserContext.generate_token(user))
      |> render(:password_reset)
    
    send(email)
  end

  defp base_email do
    new_email()
    |> from(@from)
    |> put_html_layout({PhoenixChina.Web.LayoutView, "email.html"})
  end
end