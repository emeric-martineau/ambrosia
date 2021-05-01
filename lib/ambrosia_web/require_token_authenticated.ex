defmodule AmbrosiaWeb.RequireTokenAuthenticated do
  @moduledoc """
  This plug ensures that call contain user token for API auth.

  You can see `Pow.Phoenix.PlugErrorHandler` for an example of the error
  handler module.

  ## Example

      plug AmbrosiaWeb.RequireTokenAuthenticated,
        error_handler: MyApp.CustomErrorHandler
  """
  import Ecto.Query, warn: false

  alias Plug.Conn
  alias Pow.{Config, Plug, Operations}
  alias Ambrosia.Repo
  alias Ambrosia.Users.UserToken

  @doc false
  @spec init(Config.t()) :: atom()
  def init(config) do
    Config.get(config, :error_handler) || raise_no_error_handler()
  end

  @doc false
  @spec call(Conn.t(), atom()) :: Conn.t()
  def call(conn, handler) do
    authorization = fetch_authorization(conn)

    check_authorize_head(authorization, conn, handler)
  end

  # If no 'Authorization' header not found in request, check with cookie.
  @spec check_authorize_head(String.t(), Conn.t(), Handler.t()) :: Conn.t()
  defp check_authorize_head(nil, conn, handler) do
    conn
    |> Plug.current_user()
    |> maybe_halt(conn, handler)
  end

  # Check the authorization method.
  @spec check_authorize_head(String.t(), Conn.t(), Handler.t()) :: Conn.t()
  defp check_authorize_head(authorization, conn, handler) do
    [method, token] = String.split(authorization, " ")

    method = String.downcase(String.trim(method))
    token = String.trim(token)

    authorize(method, token, conn, handler)
  end

  # Search 'Authorization' header.
  @spec fetch_authorization(Conn.t()) :: Conn.t()
  defp fetch_authorization(conn) do
    conn
    |> get_req_header("authorization")
    |> List.first()
  end

  # The header Authorisation is found and method is "basic".
  # Login user.
  @spec authorize(String.t(), String, Conn.t(), Handler.t()) :: Conn.t()
  defp authorize("basic", auth, conn, handler) do
    credential = Base.decode64(auth)
    authorize_basic(credential, conn, handler)
  end

  # The header Authorisation is found and method is "token".
  # Search the token and user associate then put user in request.
  @spec authorize(String.t(), String, Conn.t(), Handler.t()) :: Conn.t()
  defp authorize("token", token, conn, handler) do
    UserToken
    |> Repo.get_by(token: token)
    |> find_user_by_token(conn)
    |> add_user_in_request(conn, handler)
  end

  # The header Authorisation is found but method not implement.
  # Return HTTP code 400 and stop request.
  @spec authorize(String.t(), nil, Conn.t(), nil) :: Conn.t()
  defp authorize(_method, _auth, conn, handler) do
    conn
    |> handler.call(:error_protocol)
    |> Conn.halt()
  end

  # The header Authorisation with method Basic is found. And Base64 decode is done.
  # Make user login with header.
  # If fail, return HTTP code 401 and stop request.
  @spec authorize_basic({:ok, String}, Conn.t(), Handler.t()) :: Conn.t()
  defp authorize_basic({:ok, credential}, conn, handler) do
    [user, password] = String.split(credential, ":")

    user_params = %{"email" => user, "password" => password}

    conn
    |> Plug.authenticate_user(user_params)
    |> case do
         {:ok, conn} -> conn
         {:error, conn} ->
           conn
           |> handler.call(:not_authenticated)
           |> Conn.halt()
       end
  end

  # The header Authorisation with method Basic is found. But the Base64 decode has error.
  # Return HTTP code 500 and stop the request.
  @spec authorize_basic(:error, Conn.t(), nil) :: Conn.t()
  defp authorize_basic(:error, conn, handler) do
    conn
    |> handler.call(:invalid_authorization_basic)
    |> Conn.halt()
  end

  # Search a header in request.
  defp get_req_header(%Conn{req_headers: headers}, key) when is_binary(key) do
    for {^key, value} <- headers, do: value
  end

  # The request contains a token, but this token is not found. Return nil.
  @spec find_user_by_token(nil, Conn.t()) :: nil
  defp find_user_by_token(nil, _conn), do: nil

  # The request contains a token, this token is found. Search the associate user and return it.
  @spec find_user_by_token(UserToken.t(), Conn.t()) :: User.t()
  defp find_user_by_token(user_token, conn) do
    config = Plug.fetch_config(conn)
    Operations.get_by([id: user_token.user_id], config)
  end

  # The user is not found (nil), stop the request and return 401.
  @spec add_user_in_request(nil, Conn.t(), Handler.t()) :: Conn.t()
  defp add_user_in_request(nil, conn, handler) do
    conn
    |> handler.call(:not_authenticated)
    |> Conn.halt()
  end

  # Put the user in request and continue this request.
  @spec add_user_in_request(User.t(), Conn.t(), Handler.t()) :: Conn.t()
  defp add_user_in_request(user, conn, _handler) do
    config = Plug.fetch_config(conn)
    Plug.get_plug(config).do_create(conn, user, config)
  end

  @spec raise_no_error_handler :: no_return
  defp raise_no_error_handler do
    Config.raise_error("No :error_handler configuration option provided. It's required to set this when using #{inspect __MODULE__}.")
  end

  defp maybe_halt(nil, conn, handler) do
    conn
    |> handler.call(:not_authenticated)
    |> Conn.halt()
  end

  defp maybe_halt(_user, conn, _handler), do: conn
end
