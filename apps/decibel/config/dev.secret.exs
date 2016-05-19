use Mix.Config

# Generate with mix phoenix.gen.secret
config :decibel, Decibel.Endpoint,
  url: [host: ["0.0.0.0"]],
  secret_key_base: "3/bdVwMtcVA2gC5uE77GBfGB6lft9BjB71YsL5ZUK6Vs5z25RyPn0Z+L4VtpjL4o"

# Configure your database
config :decibel, Decibel.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "arp",
  password: "password",
  database: "arp_dev",
  #hostname: "localhost",
  hostname: "/var/run/postgresql",
  pool_size: 10
