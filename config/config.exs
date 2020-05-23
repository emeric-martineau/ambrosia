# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ambrosia,
  ecto_repos: [Ambrosia.Repo]

# Configures the endpoint
config :ambrosia, AmbrosiaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "6Qnr8pVoOaCqxaSWRhXTXaazWAUVEpKrw1nNU0t/IH18LNOATphUcmgKapW5U9Sy",
  render_errors: [view: AmbrosiaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Ambrosia.PubSub,
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

config :ambrosia, :pow,
       user: Ambrosia.Users.User,
       repo: Ambrosia.Repo,
       web_module: AmbrosiaWeb,
       extensions: [PowResetPassword, PowEmailConfirmation],
       controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
       mailer_backend: AmbrosiaWeb.Pow.Mailer,
       web_mailer_module: AmbrosiaWeb