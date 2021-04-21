defmodule AmbrosiaWeb.LocaleController do
  use AmbrosiaWeb, :controller

  def index(conn, _params) do
    render(conn, "locale.html")
  end
end
