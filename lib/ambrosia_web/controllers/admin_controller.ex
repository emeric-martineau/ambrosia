defmodule AmbrosiaWeb.AdminController do
  use AmbrosiaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end