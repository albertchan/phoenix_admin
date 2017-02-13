defmodule PhoenixAdmin.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :name, :string
      add :encrypted_password, :string
      add :last_login, :utc_datetime
      add :verified_at, :utc_datetime
      add :verification_sent_at, :utc_datetime
      add :verification_token, :string
      add :reset_sent_at, :utc_datetime
      add :reset_token, :string

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
