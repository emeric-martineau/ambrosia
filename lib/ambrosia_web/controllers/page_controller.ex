defmodule AmbrosiaWeb.PageController do
  use AmbrosiaWeb, :controller
  alias Pow.Plug

  def index(conn, _params) do
    render(conn, "index.html")
  end

  # Because <a href="" data-method="delete"> not always working
  def logout(conn, _) do
    conn
    |> Plug.delete()
    |> render("index.html")
  end

  def thank_you(conn, _params) do
    render(conn, "register_thank_you.html")
  end
end