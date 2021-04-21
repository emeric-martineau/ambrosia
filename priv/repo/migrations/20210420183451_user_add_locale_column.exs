defmodule Ambrosia.Repo.Migrations.UserAddLocalColumn do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :locale, :text
    end
  end
end
