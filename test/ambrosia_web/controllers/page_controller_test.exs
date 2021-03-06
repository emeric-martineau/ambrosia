defmodule AmbrosiaWeb.PageControllerTest do
  use AmbrosiaWeb.ConnCase
  alias AmbrosiaWeb.Router.Helpers, as: Routes

  alias Ambrosia.{Repo, Users.User}

  @password "secret1234"

  setup %{conn: conn} do
    # user = %Ambrosia.Users.User{email: "test@example.com", id: 1}
    user =
      %Ambrosia.Users.User{}
      |> User.changeset(%{email: "test@example.com", password: @password, password_confirmation: @password})
      |> Repo.insert!()

    authed_conn = Pow.Plug.assign_current_user(conn, user, [])

    {:ok, conn: conn, authed_conn: authed_conn}
  end

  test "Get home page without connected", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to &#65;mbrosia!"

    {:ok, document} = html_response(conn, 200)
                      |> Floki.parse_document()

    nodes = document
            |> Floki.find("body > div.pusher > div:nth-child(1) > div > div > div > a:nth-child(5)")

    assert length(nodes) == 1

    [{_tag_name, _attributes, children_nodes}] = nodes

    assert length(children_nodes) == 1

    assert children_nodes == ["Sign in"]
  end

  test "Get login page", %{conn: conn} do
    conn = get(conn, Routes.pow_session_path(conn, :new))
    assert html_response(conn, 200) =~ "<h1>Connect</h1>"
  end

  test "Get register page", %{conn: conn} do
    conn = get(conn, Routes.pow_registration_path(conn, :new))
    assert html_response(conn, 200) =~ "<h1>Register</h1>"
  end

  test "Get reset password", %{conn: conn} do
    conn = get(conn, Routes.pow_reset_password_reset_password_path(conn, :new))
    assert html_response(conn, 200) =~ "<h1>Reset password</h1>"
  end

  test "Login failed!", %{conn: conn} do
    # First get login page to get _csrf_token
    conn_for_session = get(conn, Routes.pow_session_path(conn, :new))
    html_response(conn_for_session, 200)

    conn_for_login = conn
    |> Plug.Test.recycle_cookies(conn_for_session)
    |> fetch_cookies()
    |> post(
      Routes.pow_session_path(conn, :create),
      %{"_csrf_token" => Plug.Conn.get_session(conn_for_session),
        "user" => %{
             "email" => "truc",
             "password" => "pass"
        }
      }
    )

    assert html_response(conn_for_login, 200) =~ "Login failed!"
  end

  test "Unauthorized profile page access", %{conn: conn} do
    conn = get(conn, Routes.pow_registration_path(conn, :edit))
    assert redirected_to(conn) =~  "/profile/login?request_path=%2Fprofile%2Fedit"
  end

  test "Authorized profile page access", %{authed_conn: authed_conn} do
    conn_profile = get(authed_conn, Routes.pow_registration_path(authed_conn, :edit))

    {:ok, document} = html_response(conn_profile, 200)
                      |> Floki.parse_document()

    nodes = document
            |> Floki.find("body > div.pusher > div:nth-child(1) > div > div > div > a:nth-child(3)")

    assert length(nodes) == 1

    [{_tag_name, _attributes, children_nodes}] = nodes

    assert length(children_nodes) == 1

    assert children_nodes == ["Edit profile"]
  end

  test "Get home page when connected", %{authed_conn: authed_conn}  do
    conn = get(authed_conn, "/")
    assert html_response(conn, 200) =~ "Welcome to &#65;mbrosia!"

    {:ok, document} = html_response(conn, 200)
                      |> Floki.parse_document()

    nodes = document
            |> Floki.find("body > div.pusher > div:nth-child(1) > div > div > div > a:nth-child(5)")

    assert length(nodes) == 1

    [{_tag_name, _attributes, children_nodes}] = nodes

    assert length(children_nodes) == 1

    assert children_nodes == ["Log out"]
  end

  test "Get thanks registration", %{conn: conn} do
    conn = get(conn, "/registration/thank-you")
    assert html_response(conn, 200) =~ "Thank you for yout registration!"
  end

  test "Test set locale", %{conn: conn} do
    cookie_key = Application.get_env(:ambrosia, :i18n)
    |> Keyword.get(:cookie_key)

    conn = get(conn, "/set-locale/fr/%2F")
    assert redirected_to(conn) == "/"

    %{cookies: cookies} = conn
    |> Plug.Conn.fetch_cookies()

    assert cookies[cookie_key] == "fr"

    conn = get(conn, Routes.pow_session_path(conn, :new))
    assert html_response(conn, 200) =~ "<h1>Connexion</h1>"
  end

  test "Test locale from http header with ponderation", %{conn: conn} do
    conn = conn
      |> Plug.Conn.put_req_header("accept-language", "fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7")
      |> get(Routes.pow_session_path(conn, :new))

    assert html_response(conn, 200) =~ "<h1>Connexion</h1>"
  end

  test "Test locale from http header with ponderation just last available", %{conn: conn} do
    conn = conn
      |> Plug.Conn.put_req_header("accept-language", "zz;q=0.9,ttt;q=0.8,fr;q=0.7")
      |> get(Routes.pow_session_path(conn, :new))

    assert html_response(conn, 200) =~ "<h1>Connexion</h1>"
  end

  test "Test locale from http header", %{conn: conn} do
    conn = conn
      |> Plug.Conn.put_req_header("accept-language", "fr")
      |> get(Routes.pow_session_path(conn, :new))

    assert html_response(conn, 200) =~ "<h1>Connexion</h1>"
  end
end
