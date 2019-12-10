defmodule FeeddevWeb.SurveyControllerTest do
  use FeeddevWeb.ConnCase

  alias Feeddev.Api
  alias Feeddev.Api.Survey

  @create_attrs %{
    access_mode: "some access_mode",
    comment: "some comment",
    create_date: ~D[2010-04-17],
    end_date: ~D[2010-04-17],
    name: "some name",
    start_date: ~D[2010-04-17],
    url: "some url"
  }
  @update_attrs %{
    access_mode: "some updated access_mode",
    comment: "some updated comment",
    create_date: ~D[2011-05-18],
    end_date: ~D[2011-05-18],
    name: "some updated name",
    start_date: ~D[2011-05-18],
    url: "some updated url"
  }
  @invalid_attrs %{access_mode: nil, comment: nil, create_date: nil, end_date: nil, name: nil, start_date: nil, url: nil}

  def fixture(:survey) do
    {:ok, survey} = Api.create_survey(@create_attrs)
    survey
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all surveys", %{conn: conn} do
      conn = get(conn, Routes.survey_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create survey" do
    test "renders survey when data is valid", %{conn: conn} do
      conn = post(conn, Routes.survey_path(conn, :create), survey: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.survey_path(conn, :show, id))

      assert %{
               "id" => id,
               "access_mode" => "some access_mode",
               "comment" => "some comment",
               "create_date" => "2010-04-17",
               "end_date" => "2010-04-17",
               "name" => "some name",
               "start_date" => "2010-04-17",
               "url" => "some url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.survey_path(conn, :create), survey: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update survey" do
    setup [:create_survey]

    test "renders survey when data is valid", %{conn: conn, survey: %Survey{id: id} = survey} do
      conn = put(conn, Routes.survey_path(conn, :update, survey), survey: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.survey_path(conn, :show, id))

      assert %{
               "id" => id,
               "access_mode" => "some updated access_mode",
               "comment" => "some updated comment",
               "create_date" => "2011-05-18",
               "end_date" => "2011-05-18",
               "name" => "some updated name",
               "start_date" => "2011-05-18",
               "url" => "some updated url"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, survey: survey} do
      conn = put(conn, Routes.survey_path(conn, :update, survey), survey: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete survey" do
    setup [:create_survey]

    test "deletes chosen survey", %{conn: conn, survey: survey} do
      conn = delete(conn, Routes.survey_path(conn, :delete, survey))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.survey_path(conn, :show, survey))
      end
    end
  end

  defp create_survey(_) do
    survey = fixture(:survey)
    {:ok, survey: survey}
  end
end
