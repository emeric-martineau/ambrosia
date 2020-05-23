defmodule FeeddevWeb.SurveyView do
  use FeeddevWeb, :view
  alias FeeddevWeb.SurveyView

  def render("index.json", %{surveys: surveys}) do
    %{data: render_many(surveys, SurveyView, "survey.json")}
  end

  def render("show.json", %{survey: survey}) do
    %{data: render_one(survey, SurveyView, "survey.json")}
  end

  def render("survey.json", %{survey: survey}) do
    %{id: survey.id,
      name: survey.name,
      comment: survey.comment,
      url: survey.url,
      start_date: survey.start_date,
      end_date: survey.end_date,
      create_date: survey.create_date,
      access_mode: survey.access_mode}
  end
end
