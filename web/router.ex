defmodule PhoenixChina.Router do
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
  end

  pipeline :admin_browser_session do
    plug Guardian.Plug.VerifySession, key: :admin
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/", PhoenixChina do
    pipe_through [:browser, :browser_session, :admin_browser_session]

    get "/", PageController, :index
    get "/signup", UserController, :new
    post "/signup", UserController, :create
    get "/signin", SessionController, :new
    post "/signin", SessionController, :create
    get "/signout", SessionController, :delete

    resources "/posts", PostController do
       resources "/comments", CommentController, except: [:index]

       resources "/praise", PostPraiseController, as: :praise, only: [:create, :delete], singleton: true
       resources "/collect", PostCollectController, as: :collect, only: [:create, :delete], singleton: true

       put "/set_top", PostController, :set_top
       put "/cancel_top", PostController, :cancel_top
    end

    resources "/comments", CommentController, only: [] do
      resources "/praise", CommentPraiseController, as: :praise, only: [:create, :delete], singleton: true
    end

    resources "/users", UserController, param: "username", only: [:show]
  end

  scope "/users", PhoenixChina do
     pipe_through [:browser, :browser_session]

    #  get "/:username", UserController, :show
     get "/:username/avatar", UserController, :avatar
     get "/:username/posts", PostController, :user_posts
     get "/:username/comments", UserController, :comments
     get "/:username/collects", UserController, :collects
     get "/:username/follower", UserController, :follower
     get "/:username/followed", UserController, :followed

     get "/password/forget", UserController, :password_forget
     post "/password/forget", UserController, :post_password_forget

     get "/password/reset", UserController, :password_reset
     put "/password/reset", UserController, :put_password_reset

     post "/:username/follows", UserFollowController, :create
     delete "/:username/follows", UserFollowController, :cancel
  end

  scope "/settings", PhoenixChina do
    pipe_through [:browser, :browser_session]

    get "/profile", UserController, :profile
    put "/profile", UserController, :put_profile

    get "/account", UserController, :account
    put "/account", UserController, :put_account
  end

  scope "/auth", PhoenixChina do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  scope "/notifications", PhoenixChina do
     pipe_through [:browser, :browser_session]

     get "/default", NotificationController, :default
     put "/readall", NotificationController, :readall
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", PhoenixChina do
    pipe_through :api

    post "/upload", API.V1.UploadController, :create
  end


end
