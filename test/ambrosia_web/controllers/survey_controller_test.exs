defmodule AmbrosiaWeb.SurveyControllerTest do
  use AmbrosiaWeb.ConnCase
  alias AmbrosiaWeb.Router.Helpers, as: Routes

  alias Ambrosia.{Repo, Users.User}

  @password "secret1234"
  @survey_test_name "test survey"

  setup %{conn: conn} do
    # user = %Ambrosia.Users.User{email: "test@example.com", id: 1}
    user =
      %Ambrosia.Users.User{}
      |> User.changeset(%{email: "test@example.com", password: @password, password_confirmation: @password})
      |> Repo.insert!()

    authed_conn = Pow.Plug.assign_current_user(conn, user, [])

    {:ok, conn: conn, authed_conn: authed_conn}
  end

  test "Get list of survey when not connected", %{conn: conn} do
    conn = get(conn, Routes.survey_path(conn, :index))
    assert conn.status == 401
  end

  test "Create a survey", %{authed_conn: authed_conn} do
    survey_send = [
      survey: [
        access_mode: "email",
        create_date: "2019-01-01",
        end_date: "2019-01-01",
        name: @survey_test_name,
        start_date: "2019-01-01",
        create_by: authed_conn.assigns.current_user.id
      ]
    ]

    conn = post(authed_conn, Routes.survey_path(authed_conn, :create), survey_send)

    survey_result = %{
      "access_mode" => "email",
      "create_date" => "2019-01-01",
      "end_date" => "2019-01-01",
      "name" => @survey_test_name,
      "start_date" => "2019-01-01",
      "comment" => nil,
      "url" => nil
    }

    %{"data" => survey_return} = json_response(conn, 201)
    survey_return = Map.delete(survey_return, "id")

    assert survey_return == survey_result
  end

  test "Remove test survey", %{authed_conn: authed_conn} do
    survey_send = [
      survey: [
        access_mode: "email",
        create_date: "2019-01-01",
        end_date: "2019-01-01",
        name: @survey_test_name,
        start_date: "2019-01-01",
        create_by: authed_conn.assigns.current_user.id
      ]
    ]

    conn = post(authed_conn, Routes.survey_path(authed_conn, :create, survey_send))

    assert conn.status == 201

    conn = get(authed_conn, Routes.survey_path(authed_conn, :index))

    list_of_survey = json_response(conn, 200)
    survey = List.first(list_of_survey["data"])
    id = survey["id"]

    conn = delete(authed_conn, Routes.survey_path(authed_conn, :delete, id))

    assert conn.status == 204
  end

  test "Get survey by id", %{authed_conn: authed_conn} do
    survey_send = [
      survey: [
        access_mode: "email",
        create_date: "2019-01-01",
        end_date: "2019-01-01",
        name: "Not the same test!",
        start_date: "2019-01-01",
        create_by: authed_conn.assigns.current_user.id
      ]
    ]

    conn = post(authed_conn, Routes.survey_path(authed_conn, :create, survey_send))
    %{"data" => survey_return} = json_response(conn, 201)
    id = survey_return["id"]

    conn = get(authed_conn, Routes.survey_path(authed_conn, :show, id))
    %{"data" => survey_get} = json_response(conn, 200)

    assert survey_get == survey_return
  end

  test "Update survey by PUT http verb", %{authed_conn: authed_conn} do
    survey_send = [
      survey: [
        access_mode: "email",
        create_date: "2019-01-01",
        end_date: "2019-01-01",
        name: @survey_test_name,
        start_date: "2019-01-01",
        create_by: authed_conn.assigns.current_user.id
      ]
    ]

    conn = post(authed_conn, Routes.survey_path(authed_conn, :create, survey_send))
    %{"data" => survey_return} = json_response(conn, 201)
    id = survey_return["id"]

    survey_update = [
      survey: [
        name: "Name updated"
      ]
    ]

    conn = put(authed_conn, Routes.survey_path(authed_conn, :update, id, survey_update))
    %{"data" => survey_return_put} = json_response(conn, 200)

    conn = get(authed_conn, Routes.survey_path(authed_conn, :show, id))
    %{"data" => survey_get} = json_response(conn, 200)

    assert survey_get == survey_return_put
  end

  test "Update survey by PATCH http verb", %{authed_conn: authed_conn} do
    survey_send = [
      survey: [
        access_mode: "email",
        create_date: "2019-01-01",
        end_date: "2019-01-01",
        name: @survey_test_name,
        start_date: "2019-01-01",
        create_by: authed_conn.assigns.current_user.id
      ]
    ]

    conn = post(authed_conn, Routes.survey_path(authed_conn, :create, survey_send))
    %{"data" => survey_return} = json_response(conn, 201)
    id = survey_return["id"]

    survey_update = [
      survey: [
        name: "Name updated"
      ]
    ]

    conn = patch(authed_conn, Routes.survey_path(authed_conn, :update, id, survey_update))
    %{"data" => survey_return_patch} = json_response(conn, 200)

    conn = get(authed_conn, Routes.survey_path(authed_conn, :show, id))
    %{"data" => survey_get} = json_response(conn, 200)

    assert survey_get == survey_return_patch
  end
end
