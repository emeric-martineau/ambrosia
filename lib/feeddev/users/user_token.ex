defmodule Feeddev.Users.UserToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users_token" do
    field :token, :string
    belongs_to :user, Feeddev.Users.User

    timestamps()
  end

  @doc false
  def changeset(user_token, attrs) do
    user_token
    |> cast(attrs, [:token])
    |> unique_constraint(:name_your_constraint, name: :your_index_name)
    |> Ecto.Changeset.put_assoc(:user, attrs.user)
    |> validate_required([:token, :user])
  end
end
