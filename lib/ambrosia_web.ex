defmodule AmbrosiaWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use AmbrosiaWeb, :controller
      use AmbrosiaWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: AmbrosiaWeb

      import Plug.Conn
      import AmbrosiaWeb.Gettext
      alias AmbrosiaWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/ambrosia_web/templates",
        namespace: AmbrosiaWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import AmbrosiaWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import AmbrosiaWeb.ErrorHelpers
      import AmbrosiaWeb.Gettext
      alias AmbrosiaWeb.Router.Helpers, as: Routes

      
      def render_locale(assigns \\ []) do
        a = Keyword.has_key?(assigns, :default_value)
        |> update_locale_context(assigns)
        
        render(AmbrosiaWeb.LocaleView, "locale.html", a)
      end

      defp update_locale_context(true, assigns), do: Keyword.merge(assigns, [list_locale: AmbrosiaWeb.Gettext.get_locales_text()])
      
      defp update_locale_context(false, assigns) do
        assigns
        |> Keyword.merge([list_locale: AmbrosiaWeb.Gettext.get_locales_text(), default_value: Gettext.get_locale(AmbrosiaWeb.Gettext)])
      end
    end
  end

  def mailer_view do
    quote do
      use Phoenix.View, root: "lib/ambrosia_web/templates",
                        namespace: AmbrosiaWeb

      use Phoenix.HTML
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
