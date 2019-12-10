defmodule Feeddev.Repo do
  use Ecto.Repo,
    otp_app: :feeddev,
    adapter: Ecto.Adapters.Postgres
end
