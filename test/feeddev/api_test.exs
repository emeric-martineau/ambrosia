defmodule Feeddev.ApiTest do
  use Feeddev.DataCase

  alias Feeddev.Api

  describe "surveys" do
    alias Feeddev.Api.Survey

    @valid_attrs %{access_mode: "some access_mode", comment: "some comment", create_date: ~D[2010-04-17], end_date: ~D[2010-04-17], name: "some name", start_date: ~D[2010-04-17], url: "some url"}
    @update_attrs %{access_mode: "some updated access_mode", comment: "some updated comment", create_date: ~D[2011-05-18], end_date: ~D[2011-05-18], name: "some updated name", start_date: ~D[2011-05-18], url: "some updated url"}
    @invalid_attrs %{access_mode: nil, comment: nil, create_date: nil, end_date: nil, name: nil, start_date: nil, url: nil}

    def survey_fixture(attrs \\ %{}) do
      {:ok, survey} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Api.create_survey()

      survey
    end

    test "list_surveys/0 returns all surveys" do
      survey = survey_fixture()
      assert Api.list_surveys() == [survey]
    end

    test "get_survey!/1 returns the survey with given id" do
      survey = survey_fixture()
      assert Api.get_survey!(survey.id) == survey
    end

    test "create_survey/1 with valid data creates a survey" do
      assert {:ok, %Survey{} = survey} = Api.create_survey(@valid_attrs)
      assert survey.access_mode == "some access_mode"
      assert survey.comment == "some comment"
      assert survey.create_date == ~D[2010-04-17]
      assert survey.end_date == ~D[2010-04-17]
      assert survey.name == "some name"
      assert survey.start_date == ~D[2010-04-17]
      assert survey.url == "some url"
    end

    test "create_survey/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Api.create_survey(@invalid_attrs)
    end

    test "update_survey/2 with valid data updates the survey" do
      survey = survey_fixture()
      assert {:ok, %Survey{} = survey} = Api.update_survey(survey, @update_attrs)
      assert survey.access_mode == "some updated access_mode"
      assert survey.comment == "some updated comment"
      assert survey.create_date == ~D[2011-05-18]
      assert survey.end_date == ~D[2011-05-18]
      assert survey.name == "some updated name"
      assert survey.start_date == ~D[2011-05-18]
      assert survey.url == "some updated url"
    end

    test "update_survey/2 with invalid data returns error changeset" do
      survey = survey_fixture()
      assert {:error, %Ecto.Changeset{}} = Api.update_survey(survey, @invalid_attrs)
      assert survey == Api.get_survey!(survey.id)
    end

    test "delete_survey/1 deletes the survey" do
      survey = survey_fixture()
      assert {:ok, %Survey{}} = Api.delete_survey(survey)
      assert_raise Ecto.NoResultsError, fn -> Api.get_survey!(survey.id) end
    end

    test "change_survey/1 returns a survey changeset" do
      survey = survey_fixture()
      assert %Ecto.Changeset{} = Api.change_survey(survey)
    end
  end
end
