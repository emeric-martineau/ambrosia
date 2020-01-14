defmodule FeeddevWeb.PageController do
  use FeeddevWeb, :controller

  alias Feeddev.Users.UserToken
  alias Feeddev.Repo
  alias Pow.Ecto.Schema.Changeset, as: User
  alias Phoenix.Controller
  alias Pow.Plug

  def index(conn, _params) do
    render(conn, "index.html")
  end

  # Because <a href="" data-method="delete"> not always working
  def logout(conn, _) do
    {:ok, conn} = Plug.clear_authenticated_user(conn)

    render(conn, "index.html")
  end

  # Call from edit profile to generate token
  # TODO check if user login
  def generate_token(conn, _params = %{"token" => token_form}) do
    config = Plug.fetch_config(conn)
    user = Plug.current_user(conn)

    user
    |> User.verify_password(token_form["current_password"], config)
    |> create_token(conn, user)
    |> redirect(to: token_form["return_page"])
  end

  defp create_token(true, conn, user) do
    attrs = %{
      :create_at => DateTime.utc_now(),
      :token => Pow.UUID.generate(),
      :user => user
    }

    %UserToken{}
    |> UserToken.changeset(attrs)
    |> Repo.insert()

    # TODO if error display on form

    conn
  end

  defp create_token(false, conn, _user) do
    # TODO put standard message
    IO.inspect "FAILLLLLLL"
    Controller.put_flash(conn, :error, "Invalid password")
  end
end