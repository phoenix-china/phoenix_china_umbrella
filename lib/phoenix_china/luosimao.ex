defmodule PhoenixChina.Luosimao do

  @config Application.get_env(:phoenix_china, __MODULE__)
  @captcha_verify_api "https://captcha.luosimao.com/api/site_verify"

  def captcha_site_key() do
    @config[:site_key] 
  end

  def captcha_verify?(response) do
    headers = [
      "User-Agent": "PhoenixChina",
      "Content-Type": "application/x-www-form-urlencoded"
    ]
    body = "api_key=#{@config[:api_key]}&response=#{response}"
    data = [body: body, headers: headers]
    response = HTTPotion.post @captcha_verify_api, data
    response.body =~ "success"
  end

end
