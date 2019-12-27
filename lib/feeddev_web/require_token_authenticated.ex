defmodule FeeddevWeb.RequireTokenAuthenticated do
  @moduledoc """
  This plug ensures that call contain user token for API auth.

  You can see `Pow.Phoenix.PlugErrorHandler` for an example of the error
  handler module.

  ## Example

      plug FeeddevWeb.RequireTokenAuthenticated,
        error_handler: MyApp.CustomErrorHandler
  """
  alias Plug.Conn

  @doc false
  @spec init(Config.t()) :: atom()
  def init(config) do
    Pow.Plug.RequireAuthenticated.init(config)
  end
# TODO put Pow.Plug.RequireAuthenticated in handler
  @doc false
  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, handler) do
    authorization = fetch_authorization(conn)

    check_authorize_head(authorization, conn, handler)
# Check "Authorization: token TOKEN"
#      curl --header "Authorization: 123" http://localhost:4000/api/v1/survey

  end

  defp check_authorize_head(nil, conn, handler), do: Pow.Plug.RequireAuthenticated.call(conn, handler)

  defp check_authorize_head(authorization, conn, handler) do
    [method, token] = String.split(authorization, " ")

    method = String.downcase(String.trim(method))
    token = String.trim(token)

    authorize(method, token, conn, handler)
  end

  defp fetch_authorization(conn) do
    conn
    |> get_req_header("authorization")
    |> List.first()
  end

  defp authorize("basic", auth, conn, handler) do
    credential = Base.decode64(auth)
    authorize_basic(credential, conn, handler)
  end

  defp authorize("token", auth, conn, _handler) do
    IO.inspect("token")
# TODO create users_token table with user_id, token, create_date
    config = Pow.Plug.fetch_config(conn)
    IO.inspect("--------------------------------------------------------------------------------------")
    Pow.Operations.get_by([id: 79], config)
    |> IO.inspect

    IO.inspect("--------------------------------------------------------------------------------------")

    conn
  end

  defp authorize(method, _auth, conn, _handler) do
    conn
    |> Conn.resp(400, "Authorization protocol '#{method}' not available!")
    |> Conn.halt()
  end

  defp authorize_basic({:ok, credential}, conn, handler) do
    [user, password] = String.split(credential, ":")

    user_params = %{"email" => user, "password" => password}

    conn
    |> Pow.Plug.authenticate_user(user_params)
    |> case do
         {:ok, conn} -> conn
         {:error, conn} ->
           conn
           |> handler.call(:not_authenticated)
           |> Conn.halt()
       end
  end

  defp authorize_basic(:error, conn, _handler) do
    conn
    |> Conn.resp(500, "Invalid Authorization Basic information! Base64 error.")
    |> Conn.halt()
  end

  def get_req_header(%Conn{req_headers: headers}, key) when is_binary(key) do
    for {^key, value} <- headers, do: value
  end
end

"""
Dans Plug
@spec authenticate_user(Conn.t(), map()) :: {:ok | :error, Conn.t()}
def authenticate_user(conn, params) do
  config = fetch_config(conn)

  params
  |> Operations.authenticate(config)
  |> case do
       nil  -> {:error, conn}
       user -> {:ok, get_plug(config).do_create(conn, user, config)}
     end
end

Dans Operations
  @spec get_by(Keyword.t() | map(), Config.t()) :: map() | nil
  def get_by(clauses, config) do
    case context_module(config) do
      Context -> Context.get_by(clauses, config)
      module  -> module.get_by(clauses)
    end
  end
"""