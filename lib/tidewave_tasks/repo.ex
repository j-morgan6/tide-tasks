defmodule TidewaveTasks.Repo do
  use Ecto.Repo,
    otp_app: :tidewave_tasks,
    adapter: Ecto.Adapters.Postgres
end
