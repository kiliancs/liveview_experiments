# Since configuration is shared in umbrella projects, this file
# should only configure the :centralized_live_state_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :centralized_live_state_web,
  generators: [context_app: :centralized_live_state]

# Configures the endpoint
config :centralized_live_state_web, CentralizedLiveStateWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "xtJG6FdzCmo9gbSfJZgxmTRYzSXPcI5ch96HaIAPF2xEc+u3q0JY6Mb/4l3qvqTn",
  render_errors: [view: CentralizedLiveStateWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CentralizedLiveStateWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
