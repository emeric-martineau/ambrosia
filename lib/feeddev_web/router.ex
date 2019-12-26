defmodule FeeddevWeb.Router do
  use FeeddevWeb, :router
  use Pow.Phoenix.Router
  use Pow.Extension.Phoenix.Router,
      extensions: [PowResetPassword, PowEmailConfirmation]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Protect by HTML page with login box
  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
         error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :api_protected do
    # Pow.Plug.RequireAuthenticated
    plug FeeddevWeb.RequireTokenAuthenticated, error_handler: FeeddevWeb.ApiAuthErrorHandler
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
    pow_extension_routes()
  end

  scope "/", FeeddevWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/session/logout", PageController, :logout
  end

  scope "/api/", FeeddevWeb.Api, as: :api_v1 do
    pipe_through :api

    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, singleton: true, only: [:renew]
  end

  scope "/api/v1", FeeddevWeb do
     pipe_through [:api, :api_protected]

     resources "/survey", SurveyController
  end
end
