defmodule Feeddev.Repo.Migrations.CreateSurveys do
  use Ecto.Migration

  def change do
    create table(:surveys) do
      add :name, :string
      add :comment, :string
      add :url, :string
      add :start_date, :date
      add :end_date, :date
      add :create_date, :date
      add :access_mode, :string
      add :create_by, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:surveys, [:create_by])
  end
end
