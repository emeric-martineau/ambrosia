defmodule AmbrosiaWeb.AdminControllerTest do
  use AmbrosiaWeb.ConnCase

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

  test "Get Admin with logged user", %{authed_conn: authed_conn} do
    conn = get(authed_conn, Routes.admin_path(authed_conn, :index))
    assert html_response(conn, 200) =~ "Call API with user/password"
  end

  test "Unauthorized admin page access", %{conn: conn} do
    conn = get(conn, Routes.admin_path(conn, :index))
    assert html_response(conn, 302) =~ "redirected"
  end

  test "Create tocken invalid password", %{authed_conn: authed_conn} do
    user = [
      token: [
        current_password: "email"
      ]
    ]

    conn = post(authed_conn, Routes.advanced_config_user_path(authed_conn, :generate_token, user))
    assert html_response(conn, 200) =~ "is invalid"
  end

  test "Create tocken", %{authed_conn: authed_conn} do
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
  end
end
