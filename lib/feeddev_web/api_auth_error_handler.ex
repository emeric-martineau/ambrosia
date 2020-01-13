defmodule FeeddevWeb.ApiAuthErrorHandler do
  use FeeddevWeb, :controller
  alias Plug.Conn

  @spec call(Conn.t(), :not_authenticated) :: Conn.t()
  def call(conn, :not_authenticated) do
    conn
    |> put_status(401)
    |> json(%{error: %{code: 401, message: "Not authenticated"}})
  end

  @spec call(Conn.t(), :invalid_authorization_basic) :: Conn.t()
  def call(conn, :invalid_authorization_basic) do
    conn
    |> put_status(500)
    |> json(%{error: %{code: 500, message: "Invalid Authorization Basic information! Base64 error"}})
  end

  @spec call(Conn.t(), :error_protocol) :: Conn.t()
  def call(conn, :error_protocol) do
    conn
    |> put_status(500)
    |> json(%{error: %{code: 400, message:  "This authorization protocol not available!"}})
  end
end