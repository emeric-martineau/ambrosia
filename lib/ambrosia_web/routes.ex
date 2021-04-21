defmodule AmbrosiaWeb.Routes do
  # This macro help to declare route that can be support localization.
  defmacro routes() do
    quote do

      scope "/", AmbrosiaWeb do
        pipe_through [:browser, :internationalization]

        get "/", PageController, :index
      end

      scope "/set-locale/", AmbrosiaWeb do
        pipe_through [:browser]

        get "/:locale/:url", PageController, :set_locale
      end

      scope "/profile", Pow.Phoenix, as: "pow" do
        pipe_through [:browser]

        get "/edit", RegistrationController, :edit
        get "/login", SessionController, :new
      end

      scope "/profile", AmbrosiaWeb do
        pipe_through [:browser, :protected]

        get "/logout", PageController, :logout
        get "/advanced", Users.AdvancedConfigUserController, :index
        get "/advanced/tokens/delete/:id", Users.AdvancedConfigUserController, :delete_token
        post "/update", Users.AdvancedConfigUserController, :update
      end

      scope "/admin", AmbrosiaWeb do
        pipe_through [:browser, :protected, :admin_layout]

        get "/", AdminController, :index
      end

      scope "/profile", AmbrosiaWeb do
        pipe_through :protected

        post "/advanced/tokens", Users.AdvancedConfigUserController, :generate_token
      end

      scope "/confirm-email", PowEmailConfirmation.Phoenix, as: "pow_email_confirmation" do
        pipe_through [:browser]

        get "/:id", ConfirmationController, :show
      end

      scope "/reset-password/new", PowResetPassword.Phoenix, as: "pow" do
        pipe_through [:browser]

        get "/", ResetPasswordController, :new
      end

      scope "/registration", Pow.Phoenix, as: "pow" do
        pipe_through [:browser]

        get "/new", RegistrationController, :new
      end

      scope "/reset-password", PowResetPassword.Phoenix, as: "pow_reset_password" do
        pipe_through [:browser]

        get "/:id", ResetPasswordController, :edit
        get "/", ResetPasswordController, :new
      end

      scope "/registration", AmbrosiaWeb do
        pipe_through [:browser]

        get "/thank-you", PageController, :thank_you
      end

      scope "/profile", Pow.Phoenix, as: "pow" do
        pipe_through :browser

        patch "/edit", RegistrationController, :update
        put "/edit", RegistrationController, :update

        post "/login", SessionController, :create
        delete "/logout", SessionController, :delete
      end

      scope "/registration", Pow.Phoenix, as: "pow" do
        pipe_through :browser

        post "/", RegistrationController, :create
        patch "/", RegistrationController, :update
        put "/", RegistrationController, :update
        delete "/", RegistrationController, :delete
      end

      scope "/reset-password", PowResetPassword.Phoenix, as: "pow_reset_password" do
        pipe_through :browser

        post "/", ResetPasswordController, :create
        patch "/:id", ResetPasswordController, :update
        put "/:id", ResetPasswordController, :update
      end
    end
  end

  @doc false
  defmacro __using__(_opts \\ []) do
    quote do

    end
  end
end
