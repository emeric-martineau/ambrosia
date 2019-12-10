defmodule Feeddev.Api.Survey do
  use Ecto.Schema
  import Ecto.Changeset

  schema "surveys" do
    field :access_mode, :string
    field :comment, :string
    field :create_date, :date
    field :end_date, :date
    field :name, :string
    field :start_date, :date
    field :url, :string
    field :create_by, :id

    timestamps()
  end

  @doc false
  def changeset(survey, attrs) do
    survey
    |> cast(attrs, [:name, :comment, :url, :start_date, :end_date, :create_date, :access_mode])
    |> validate_required([:name, :start_date, :end_date, :create_date, :access_mode])
  end
end
