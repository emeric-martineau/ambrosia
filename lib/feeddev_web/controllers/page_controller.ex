defmodule FeeddevWeb.PageController do
  use FeeddevWeb, :controller
  alias Pow.Plug

  def index(conn, _params) do
    render(conn, "index.html")
  end

  # Because <a href="" data-method="delete"> not always working
  def logout(conn, _) do
    {:ok, conn} = Plug.clear_authenticated_user(conn)

    render(conn, "index.html")
  end
end