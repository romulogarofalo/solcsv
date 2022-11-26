import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :solcsv, Solcsv.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "solcsv_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :solcsv, SolcsvWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "vMfqkxhIkw0FMbwyDDJUZawwzt8yW9fTJxCYE2EDnIqXaJyMK0ZYU9RPL4iaXG+/",
  server: false

# In test we don't send emails.
config :solcsv, Solcsv.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :solcsv, Solcsv.Ports.Viacep, adapter: SolcsvAdapters.ViacepAdapterMock

config :solcsv, SolcsvAdapters.ViacepAdapter,
  base_url: "testurl",
  timeout: 10_000

config :tesla, adapter: TeslaMock

config :solcsv, Oban, testing: :inline
