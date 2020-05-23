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

  pipeline :admin_layout do
    plug :put_layout, {FeeddevWeb.LayoutView, :admin}
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
    get "/register/thank-you", PageController, :thank_you
  end

  scope "/profile", FeeddevWeb do
    pipe_through [:browser, :protected]

    get "/", PageController, :index
    get "/logout", PageController, :logout
    get "/advanced", Users.AdvancedConfigUserController, :index
    post "/advanced/tokens", Users.AdvancedConfigUserController, :generate_token
    get "/advanced/tokens/delete/:id", Users.AdvancedConfigUserController, :delete_token
  end

  scope "/admin", FeeddevWeb do
    pipe_through [:browser, :protected, :admin_layout]

    get "/", AdminController, :index
  end

  scope "/api/v1", FeeddevWeb do
    pipe_through [:api, :api_protected]

    resources "/survey", SurveyController
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: FeeddevWeb.Telemetry
    end
  end
end
