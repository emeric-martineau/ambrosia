defmodule AmbrosiaWeb.Users.AdvancedConfigUserControllerTest do
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

  test "Create a token, get list then delete", %{authed_conn: authed_conn} do
    # Create tocken
    post(
      authed_conn,
      Routes.advanced_config_user_path(authed_conn, :generate_token),
      %{
        "token" => %{
          "current_password" => @password
        }
      })

    # Get list page where token store
    conn_get_list = get(authed_conn, Routes.advanced_config_user_path(authed_conn, :index))

    {:ok, document} = html_response(conn_get_list, 200)
    |> Floki.parse_document()

    nodes = document
    |> Floki.find("table.ui > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(2)")

    assert length(nodes) == 1

    [{_tag_name, _attributes, children_nodes}] = nodes

    assert length(children_nodes) == 1

    # Now delete token
    [id_token] = children_nodes
    conn_delete = get(authed_conn, Routes.advanced_config_user_path(authed_conn, :delete_token, Phoenix.Param.to_param(id_token)))

    {:ok, document} = html_response(conn_delete, 200)
                      |> Floki.parse_document()

    nodes = document
    |> Floki.find("table.ui > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(2)")

    assert length(nodes) == 0
  end

  test "Unauthorized profile page access", %{conn: conn} do
    conn = get(conn, Routes.advanced_config_user_path(conn, :index))
    assert redirected_to(conn) =~  Routes.pow_session_path(conn, :new)
  end
end
