defmodule PhoenixChina.Luosimao do

  @config Application.get_env(:phoenix_china, __MODULE__)
  @captcha_verify_api "https://captcha.luosimao.com/api/site_verify"

  def captcha_site_key() do
    @config[:site_key]
  end

  def captcha_verify?(response) do
    data = [
      headers: [
        "User-Agent": "PhoenixChina",
        "Content-Type": "application/x-www-form-urlencoded"
      ],
      body: URI.encode_query(%{
        "api_key" => @config[:api_key],
        "response" => response
      }),
    ]

    response = HTTPotion.post @captcha_verify_api, data
    response.body =~ "success"
  end

end
