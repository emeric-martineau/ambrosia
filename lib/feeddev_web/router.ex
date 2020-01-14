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
  end

  scope "/profile", FeeddevWeb do
    pipe_through [:browser, :protected]

    get "/", PageController, :index
    get "/logout", PageController, :logout
    post "/generate_token", PageController, :generate_token
  end

  scope "/api/v1", FeeddevWeb do
     pipe_through [:api, :api_protected]

     resources "/survey", SurveyController
  end
end
