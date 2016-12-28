defmodule PhoenixChina.Plug.MobileHtml do

  @doc """
  https://github.com/elixytics/ua_inspector
  Maby use ua_inspector to  parser User agent is better~ 

  1. update pipeline

    pipeline :browser do
      ...
      plug PhoenixChina.Plug.MobileHtml
    end

  2. add route

    post "/site/mobile_preference", MobilePreferenceController, :create

  3. create mobile layout

    web/templates/layout/app.mobile.html.eex

  4. create template

    web/templates/page/index.mobile.html.eex

  5. in index.mobile.html.eex add switch to desktop button

    <%= link to: mobile_preference_path(@conn, :create), method: :post do %>
      <input type="hidden" name="mobile" value="false">
      <button>切换到桌面版</button>
    <%= end %>

  6. in index.html.eex add switch to mobile button.

    <%= link to: mobile_preference_path(@conn, :create), method: :post do %>
      <input type="hidden" name="mobile" value="true">
      <button>切换到手机版</button>
    <%= end %>

  7. js is show switch to mobile button

  8. change controller render

    render("index.html") => render(:index)
  """

  import Plug.Conn
  import Phoenix.Controller
  
  def init(opts \\ %{}), do: Enum.into(opts, %{})

  def call(conn, _opts) do
    conn
    |> judge_platform
    |> set_format
  end

  defp judge_platform(conn) do
    user_agent = 
      conn 
      |> get_req_header("user-agent") 
      |> hd
    
    mobile? = 
      cond do
        user_agent =~ "Android" -> true
        user_agent =~ "Mobile" -> true
        true -> false
      end
    
    unset? =
      conn
      |> get_session(:mobile)
      |> is_nil

    case mobile? && unset? do
      true -> put_session(conn, :mobile, "true")
      false -> conn
    end
  end

  defp set_format(conn) do
    case get_session(conn, :mobile) do
      "true" ->
        conn
        |> put_format("mobile.html")
        |> put_layout_formats(layout_formats(conn) ++ ["mobile.html"])
        |> put_resp_content_type("text/html; charset=utf-8")

      _ -> conn
    end
  end
end