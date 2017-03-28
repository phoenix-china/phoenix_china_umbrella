defmodule PhoenixChina.Web.Router do
  use PhoenixChina.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug PhoenixChina.Guardian.CurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixChina.Web do
    pipe_through [:browser, :browser_session] # Use the default browser stack

    get "/", PageController, :index

    get "/join", UserController, :new
    post "/join", UserController, :create

    get "/login", SessionController, :new
    post "/login", SessionController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixChina.Web do
  #   pipe_through :api
  # end
end
