defmodule Ambrosia.Repo.Migrations.CreateUsersToken do
  use Ecto.Migration

  def change do
    create table(:users_token) do
      add :create_at, :date
      add :token, :string, null: true
      add :user_id, references(:users), on_delete: :nothing, null: false

      timestamps()
    end

    create index(:users_token, [:user_id])
    create unique_index(:users_token, [:token])
  end
end
