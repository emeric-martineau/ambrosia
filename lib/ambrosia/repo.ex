defmodule Ambrosia.Repo do
  use Ecto.Repo,
    otp_app: :ambrosia,
    adapter: Ecto.Adapters.Postgres
end
