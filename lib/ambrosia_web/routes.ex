defmodule AmbrosiaWeb.Routes do
  # This macro help to declare route that can be support localization.
  defmacro ambrosia_routes(prefix_path) do
    quote do
      scope unquote(prefix_path) do
        scope "/profile", Pow.Phoenix, as: "pow" do
          pipe_through [:browser, :internationalization]

          get "/edit", RegistrationController, :edit
          get "/login", SessionController, :new
        end

        scope "/profile", AmbrosiaWeb do
          pipe_through [:browser, :internationalization, :protected]

          get "/logout", PageController, :logout
          get "/advanced", Users.AdvancedConfigUserController, :index
          get "/advanced/tokens/delete/:id", Users.AdvancedConfigUserController, :delete_token
        end
      end

      scope unquote(prefix_path) <> "/admin", AmbrosiaWeb do
        pipe_through [:browser, :internationalization, :protected, :admin_layout]

        get "/", AdminController, :index
      end

      scope unquote(prefix_path) <> "/confirm-email", PowEmailConfirmation.Phoenix, as: "pow" do
        pipe_through [:browser, :internationalization]

        get "/:id", ConfirmationController, :show
      end

      scope unquote(prefix_path) <> "/reset-password/new", PowResetPassword.Phoenix, as: "pow" do
        pipe_through [:browser, :internationalization]

        get "/", ResetPasswordController, :new
      end

      scope unquote(prefix_path) <> "/registration", Pow.Phoenix, as: "pow" do
        pipe_through [:browser, :internationalization]

        get "/new", RegistrationController, :new
      end

      scope unquote(prefix_path) <> "/reset-password", PowResetPassword.Phoenix, as: "pow_reset_password" do
        pipe_through [:browser, :internationalization]

        get "/:id", ResetPasswordController, :edit
        get "/", ResetPasswordController, :new
      end

      scope unquote(prefix_path) <> "/registration", AmbrosiaWeb do
        pipe_through [:browser, :internationalization]

        get "/thank-you", PageController, :thank_you
      end
    end
  end

  @doc false
  defmacro __using__(_opts \\ []) do
    quote do

    end
  end
end
