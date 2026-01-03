defmodule Shroom.Repo do
  use Ecto.Repo,
    otp_app: :shroom,
    adapter: Ecto.Adapters.Postgres

  def init(_, config) do
    {:ok, Keyword.put(config, :types, Shroom.PostgresTypes)}
  end
end
