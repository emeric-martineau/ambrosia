defmodule AmbrosiaWeb.PageController do
  use AmbrosiaWeb, :controller

  def index(conn, _params) do
  Pow.Plug.current_user(conn)
  |> IO.inspect()
    render(conn, "index.html")
  end

  # Because <a href="" data-method="delete"> not always working
  def logout(conn, _) do
    conn
    |> Pow.Plug.delete()
    |> render("index.html")
  end

  def thank_you(conn, _params) do
    render(conn, "register_thank_you.html")
  end

  def set_locale(conn, params) do 
      %{"url" => path, "locale" => locale} = params

      cookie_key = Application.get_env(:ambrosia, :i18n)
      |> Keyword.get(:cookie_key)

      conn
      |> Plug.Conn.put_resp_cookie(cookie_key, locale, encrypt: true)
      |> redirect(to: path)
      |> Plug.Conn.halt()
  end
end
