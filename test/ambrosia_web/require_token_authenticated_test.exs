defmodule AmbrosiaWeb.RequireTokenAuthenticatedTest do
  use AmbrosiaWeb.ConnCase

  alias Ambrosia.{Repo, Users.User}

  @username "test@example.com"
  @password "secret1234"

  setup %{conn: conn} do
    # user = %Ambrosia.Users.User{email: "test@example.com", id: 1}
    user =
      %Ambrosia.Users.User{}
      |> User.changeset(%{email: @username, password: @password, password_confirmation: @password})
      |> Repo.insert!()

    authed_conn = Pow.Plug.assign_current_user(conn, user, [])

    {:ok, conn: conn, authed_conn: authed_conn}
  end

  test "Get token after login", %{authed_conn: authed_conn} do
    user = [
      token: [
        current_password: @password
      ]
    ]

    conn = post(authed_conn, Routes.advanced_config_user_path(authed_conn, :generate_token, user))

    {:ok, document} = html_response(conn, 200)
                      |> Floki.parse_document()

    nodes = document
            |> Floki.find("table.ui > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(3) > a:nth-child(1)")

    assert length(nodes) == 1

    conn = get(authed_conn, Routes.survey_path(authed_conn, :index))
    assert conn.status == 200
  end

  test "Get token with basic auth", %{authed_conn: authed_conn, conn: conn} do
    user = [
      token: [
        current_password: @password
      ]
    ]

    authed_conn = post(authed_conn, Routes.advanced_config_user_path(authed_conn, :generate_token, user))

    {:ok, document} = html_response(authed_conn, 200)
                      |> Floki.parse_document()

    nodes = document
            |> Floki.find("table.ui > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(3) > a:nth-child(1)")

    assert length(nodes) == 1

    base64auth = Base.encode64("#{@username}:#{@password}")

    conn_with_api_header = conn
                           |> Plug.Conn.put_req_header("authorization", "Basic #{base64auth}")

    conn = get(conn_with_api_header, Routes.survey_path(conn, :index))
    assert conn.status == 200
  end

  test "Get token with token", %{authed_conn: authed_conn, conn: conn} do
    user = [
      token: [
        current_password: @password
      ]
    ]

    authed_conn = post(authed_conn, Routes.advanced_config_user_path(authed_conn, :generate_token, user))

    {:ok, document} = html_response(authed_conn, 200)
                      |> Floki.parse_document()

    nodes = document
            |> Floki.find("table.ui > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(2)")

    assert length(nodes) == 1

    [{"td", [], [token]}] = nodes

    conn_with_api_header = conn
                           |> Plug.Conn.put_req_header("authorization", "Token #{token}")

    conn = get(conn_with_api_header, Routes.survey_path(conn, :index))
    assert conn.status == 200
  end
end