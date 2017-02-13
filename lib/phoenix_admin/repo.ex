defmodule PhoenixAdmin.Repo do
  use Ecto.Repo, otp_app: :phoenix_admin
  use Scrivener, page_size: 20
end
