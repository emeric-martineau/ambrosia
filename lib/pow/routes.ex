defmodule FeeddevWeb.Pow.Routes do
  use Pow.Phoenix.Routes
  alias FeeddevWeb.Router.Helpers, as: Routes
  @impl true
  def after_registration_path(conn), do: Routes.page_path(conn, :index)
end