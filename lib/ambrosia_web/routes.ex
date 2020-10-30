defmodule AmbrosiaWeb.Routes do
  # This macro help to declare route that can be support localization.
  defmacro ambrosia_routes(prefix_path) do
    quote do
      scope unquote(prefix_path) do
        pipe_through [:browser, :internationalization]

        scope "/profile", Pow.Phoenix, as: "pow" do
          get "/edit", RegistrationController, :edit

          get "/login", SessionController, :new
        end

        scope "/profile", AmbrosiaWeb do
          pipe_through :protected

          get "/logout", PageController, :logout
          get "/advanced", Users.AdvancedConfigUserController, :index
          get "/advanced/tokens/delete/:id", Users.AdvancedConfigUserController, :delete_token
        end
      end

      scope unquote(prefix_path) <> "/admin", AmbrosiaWeb do
        pipe_through [:protected, :admin_layout]

        get "/", AdminController, :index
      end

      scope unquote(prefix_path) <> "/confirm-email", PowEmailConfirmation.Phoenix, as: "pow" do
        get "/:id", ConfirmationController, :show
      end

      scope unquote(prefix_path) <> "/reset-password", PowResetPassword.Phoenix, as: "pow" do
        get "/new", ResetPasswordController, :new
      end

      scope unquote(prefix_path) <> "/registration", Pow.Phoenix, as: "pow" do
        get "/new", RegistrationController, :new
      end

      scope unquote(prefix_path) <> "/reset-password", PowResetPassword.Phoenix, as: "pow_reset_password" do
        get "/:id", ResetPasswordController, :edit
        get "/", ResetPasswordController, :new
      end
    end
  end

  @doc false
  defmacro __using__(_opts \\ []) do
    quote do

    end
  end
end
