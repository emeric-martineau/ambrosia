defmodule AmbrosiaWeb.Routes do
  # This macro help to declare route that can be support localization.
  defmacro ambrosia_routes(prefix_path) do
    quote do
      scope unquote(prefix_path) do
        pipe_through [:browser, :internationalization]

        scope "/profile", Pow.Phoenix, as: "pow" do
          get "/edit", RegistrationController, :edit
          patch "/edit", RegistrationController, :update
          put "/edit", RegistrationController, :update

          get "/login", SessionController, :new
          post "/login", SessionController, :create
          delete "/logout", SessionController, :delete
        end

        scope "/profile", AmbrosiaWeb do
          pipe_through :protected

          get "/logout", PageController, :logout
          get "/advanced", Users.AdvancedConfigUserController, :index
          post "/advanced/tokens", Users.AdvancedConfigUserController, :generate_token
          get "/advanced/tokens/delete/:id", Users.AdvancedConfigUserController, :delete_token
        end
      end

      scope unquote(prefix_path) do
        pipe_through [:browser, :internationalization]

        pow_routes()
        pow_extension_routes()
      end

      scope unquote(prefix_path) <> "/admin", AmbrosiaWeb do
        pipe_through [:browser, :protected, :admin_layout]

        get "/", AdminController, :index
      end

    end
  end

  @doc false
  defmacro __using__(_opts \\ []) do
    quote do

    end
  end
end
