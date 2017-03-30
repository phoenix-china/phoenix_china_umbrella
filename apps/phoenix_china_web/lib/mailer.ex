defmodule PhoenixChina.Mailer do
  use Bamboo.Mailer, otp_app: :phoenix_china
end


defmodule PhoenixChina.Emails do
  import Bamboo.Email

  def welcome_email do
    # or pipe using Bamboo.Email functions
    new_email
    |> to("200006506@qq.com")
    |> from("support@phoenix-china.org")
    |> subject("Welcome!!!")
    |> html_body("<strong>Welcome</strong>")
    |> text_body("welcome")
  end
end