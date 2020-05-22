defmodule FeeddevWeb.AdminController do
  use FeeddevWeb, :controller
  alias Pow.Plug

  def index(conn, _params) do
    render(conn, "index.html")
  end
end