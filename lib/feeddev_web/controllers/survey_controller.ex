defmodule FeeddevWeb.SurveyController do
  use FeeddevWeb, :controller

  alias Feeddev.Api
  alias Feeddev.Api.Survey

  action_fallback FeeddevWeb.FallbackController

  def index(conn, _params) do
    surveys = Api.list_surveys()
    render(conn, "index.json", surveys: surveys)
  end

  def create(conn, %{"survey" => survey_params}) do
    with {:ok, %Survey{} = survey} <- Api.create_survey(survey_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.survey_path(conn, :show, survey))
      |> render("show.json", survey: survey)
    end
  end

  def show(conn, %{"id" => id}) do
    survey = Api.get_survey!(id)
    render(conn, "show.json", survey: survey)
  end

  def update(conn, %{"id" => id, "survey" => survey_params}) do
    survey = Api.get_survey!(id)

    with {:ok, %Survey{} = survey} <- Api.update_survey(survey, survey_params) do
      render(conn, "show.json", survey: survey)
    end
  end

  def delete(conn, %{"id" => id}) do
    survey = Api.get_survey!(id)

    with {:ok, %Survey{}} <- Api.delete_survey(survey) do
      send_resp(conn, :no_content, "")
    end
  end
end
