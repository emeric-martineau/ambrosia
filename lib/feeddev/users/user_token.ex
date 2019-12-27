defmodule Feeddev.Users.UserToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users_token" do
    field :create_at, :date
    field :token, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(user_token, attrs) do
    user_token
    |> cast(attrs, [:create_at, :token])
    |> validate_required([:create_at, :token])
  end
end
