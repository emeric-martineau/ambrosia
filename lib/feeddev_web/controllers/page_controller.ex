defmodule FeeddevWeb.PageController do
  use FeeddevWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
