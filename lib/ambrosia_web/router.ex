defmodule AmbrosiaWeb.Router do
  use AmbrosiaWeb, :router
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
    plug :put_layout, {AmbrosiaWeb.LayoutView, :admin}
  end

  # Protect by HTML page with login box
  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
         error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :api_protected do
    plug AmbrosiaWeb.RequireTokenAuthenticated, error_handler: AmbrosiaWeb.ApiAuthErrorHandler
  end

  scope "/", Pow.Phoenix, as: "pow" do
    pipe_through :browser

    get "/profile/edit", RegistrationController, :edit
    patch "/profile/edit", RegistrationController, :update
    put "/profile/edit", RegistrationController, :update

    get "/profile/login", SessionController, :new
    post "/profile/login", SessionController, :create
    delete "/profile/logout", SessionController, :delete
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
    pow_extension_routes()
  end

  scope "/", AmbrosiaWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/profile", AmbrosiaWeb do
    pipe_through [:browser, :protected]

    get "/logout", PageController, :logout
    get "/advanced", Users.AdvancedConfigUserController, :index
    post "/advanced/tokens", Users.AdvancedConfigUserController, :generate_token
    get "/advanced/tokens/delete/:id", Users.AdvancedConfigUserController, :delete_token
  end

  scope "/admin", AmbrosiaWeb do
    pipe_through [:browser, :protected, :admin_layout]

    get "/", AdminController, :index
  end

  scope "/api/v1", AmbrosiaWeb do
    pipe_through [:api, :api_protected]

    resources "/survey", SurveyController, only: [:index, :show, :update, :delete, :create]
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
      live_dashboard "/dashboard", metrics: AmbrosiaWeb.Telemetry
    end
  end
end
