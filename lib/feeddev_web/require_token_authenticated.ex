defmodule FeeddevWeb.RequireTokenAuthenticated do
  @moduledoc """
  This plug ensures that call contain user token for API auth.

  You can see `Pow.Phoenix.PlugErrorHandler` for an example of the error
  handler module.

  ## Example

      plug FeeddevWeb.RequireTokenAuthenticated,
        error_handler: MyApp.CustomErrorHandler
  """
  import Ecto.Query, warn: false

  alias Plug.Conn
  alias Feeddev.Repo
  alias Feeddev.Users.UserToken

  @doc false
  @spec init(Config.t()) :: atom()
  def init(config) do
    Pow.Plug.RequireAuthenticated.init(config)
  end
# TODO put Pow.Plug.RequireAuthenticated in handler
# TODO add generate token page
  @doc false
  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, handler) do
    authorization = fetch_authorization(conn)

    check_authorize_head(authorization, conn, handler)
  end

  @doc """
  If no 'Authorization' header not found in request, user next handler.
  """
  @spec check_authorize_head(String.t(), Conn.t(), Handler.t()) :: Conn.t()
  defp check_authorize_head(nil, conn, handler), do: Pow.Plug.RequireAuthenticated.call(conn, handler)

  @doc """
  Check the authorization method.
  """
  @spec check_authorize_head(String.t(), Conn.t(), Handler.t()) :: Conn.t()
  defp check_authorize_head(authorization, conn, handler) do
    [method, token] = String.split(authorization, " ")

    method = String.downcase(String.trim(method))
    token = String.trim(token)

    authorize(method, token, conn, handler)
  end

  @doc """
  Search 'Authorization' header.
  """
  @spec authorize(Conn.t()) :: Conn.t()
  defp fetch_authorization(conn) do
    conn
    |> get_req_header("authorization")
    |> List.first()
  end

  @doc """
  The header Authorisation is found and method is "basic".
  Login user.
  """
  @spec authorize(String.t(), String, Conn.t(), Handler.t()) :: Conn.t()
  defp authorize("basic", auth, conn, handler) do
    credential = Base.decode64(auth)
    authorize_basic(credential, conn, handler)
  end

  @doc """
  The header Authorisation is found and method is "token".
  Search the token and user associate then put user in request.
  """
  @spec authorize(String.t(), String, Conn.t(), Handler.t()) :: Conn.t()
  defp authorize("token", token, conn, handler) do
    IO.inspect("token")

    UserToken
    |> Repo.get_by(token: token)
    |> find_user_by_token(conn)
    |> add_user_in_request(conn, handler)
  end

  @doc """
  The header Authorisation is found but method not implement.
  Return HTTP code 400 and stop request.
  """
  @spec authorize(String.t(), nil, Conn.t(), nil) :: Conn.t()
  defp authorize(method, _auth, conn, _handler) do
    conn
    |> Conn.resp(400, "Authorization protocol '#{method}' not available!")
    |> Conn.halt()
  end

  @doc """
  The header Authorisation with method Basic is found. And Base64 decode is done.
  Make user login with header.
  If fail, return HTTP code 401 and stop request.
  """
  @spec authorize_basic({:ok, String}, Conn.t(), Handler.t()) :: Conn.t()
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

  @doc """
  The header Authorisation with method Basic is found. But the Base64 decode has error.
  Return HTTP code 500 and stop the request.
  """
  @spec authorize_basic(:error, Conn.t(), nil) :: Conn.t()
  defp authorize_basic(:error, conn, _handler) do
    conn
    |> Conn.resp(500, "Invalid Authorization Basic information! Base64 error.")
    |> Conn.halt()
  end

  @doc """
  Search a header in request.
  """
  defp get_req_header(%Conn{req_headers: headers}, key) when is_binary(key) do
    for {^key, value} <- headers, do: value
  end

  @doc """
  The request contains a token, but this token is not found. Return nil.
  """
  @spec find_user_by_token(nil, Conn.t()) :: nil
  defp find_user_by_token(nil, conn), do: nil

  @doc """
  The request contains a token, this token is found. Search the associate user and return it.
  """
  @spec find_user_by_token(UserToken.t(), Conn.t()) :: User.t()
  defp find_user_by_token(user_token, conn) do
    config = Pow.Plug.fetch_config(conn)
    Pow.Operations.get_by([id: user_token.user_id], config)
  end

  @doc """
  The user is not found (nil), stop the request and return 401.
  """
  @spec add_user_in_request(nil, Conn.t(), Handler.t()) :: Conn.t()
  defp add_user_in_request(nil, conn, handler) do
    conn
    |> handler.call(:not_authenticated)
    |> Conn.halt()
  end

  @doc """
  Put the user in request and continue this request.
  """
  @spec add_user_in_request(User.t(), Conn.t(), Handler.t()) :: Conn.t()
  defp add_user_in_request(user, conn, _handler) do
    config = Pow.Plug.fetch_config(conn)
    Pow.Plug.get_plug(config).do_create(conn, user, config)
  end
end