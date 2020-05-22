# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :feeddev,
  ecto_repos: [Feeddev.Repo]

# Configures the endpoint
config :feeddev, FeeddevWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "6Qnr8pVoOaCqxaSWRhXTXaazWAUVEpKrw1nNU0t/IH18LNOATphUcmgKapW5U9Sy",
  render_errors: [view: FeeddevWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Feeddev.PubSub,
  live_view: [signing_salt: "Hfyd0Ddu"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :feeddev, :pow,
       user: Feeddev.Users.User,
       repo: Feeddev.Repo,
       web_module: FeeddevWeb,
       extensions: [PowResetPassword, PowEmailConfirmation],
       controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
       mailer_backend: FeeddevWeb.Pow.Mailer,
       web_mailer_module: FeeddevWeb