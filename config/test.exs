import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :frosty_friend, FrostyFriendWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "VhzrMYz7XZCCVi0D+TVKtnXk/dlgfVgS8NQ70p0fj2Sx0eqD/WU59tSqJoA96HeU",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
