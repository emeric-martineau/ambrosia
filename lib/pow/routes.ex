defmodule AmbrosiaWeb.Pow.Routes do
  use Pow.Phoenix.Routes
  alias AmbrosiaWeb.Router.Helpers, as: Routes
  @impl true
  def after_registration_path(conn), do: Routes.page_path(conn, :thank_you)
end