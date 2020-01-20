defmodule FeeddevWeb.Users.AdvancedConfigUserController do
  use FeeddevWeb, :controller

  alias Feeddev.Users.UserToken
  alias Feeddev.Repo
  alias Pow.Ecto.Schema.Changeset, as: User
  alias Plug.Conn
  alias Pow.Plug

  def index(conn, _params) do
    render_index_page(%{:conn => conn, :error => []})
  end

  # Call from edit profile to generate token
  def generate_token(conn, _params = %{"token" => token_form}) do
    config = Plug.fetch_config(conn)
    user = Plug.current_user(conn)

    user
    |> check_password(token_form["current_password"], config)
    |> create_token(conn, user)
    |> render_index_page()
  end

  # If password is empty, return error message
  defp check_password(_user, "", _config) do
    [current_password: {"can't be blank", [validation: :required]}]
  end

  # If error not empty, check it and return true or false
  defp check_password(user, password, config) do
    a = User.verify_password(user, password, config)
    IO.inspect(a)

  end

  # User password is ok. Return Conn.t()
  defp create_token(true, conn, user) do
    attrs = %{
      :create_at => DateTime.utc_now(),
      :token => Pow.UUID.generate(),
      :user => user
    }

    %UserToken{}
    |> UserToken.changeset(attrs)
    |> Repo.insert()

    %{:conn => conn, :error => []}
  end

  # User password is wrong. Return error message
  defp create_token(false, conn, _user) do
    %{:conn => conn, :error => [current_password: {"is invalid", [validation: :required]}]}
  end

  # Previously we get error, return it
  defp create_token(error, conn, _user) do
    %{:conn => conn, :error => error}
  end

  defp render_index_page(_conn_and_error = %{:conn => conn, :error => error}) do
    tokens = UserToken
                |> Repo.all()

    render(conn, "index.html", data: %{:errors => error, :tokens => tokens})
  end
end
