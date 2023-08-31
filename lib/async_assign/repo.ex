defmodule AsyncAssign.Repo do
  use Ecto.Repo,
    otp_app: :async_assign,
    adapter: Ecto.Adapters.Postgres
end
