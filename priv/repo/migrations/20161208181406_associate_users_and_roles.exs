defmodule PhoenixAdmin.Repo.Migrations.AssociateUsersAndRoles do
  use Ecto.Migration

  def change do
    create table(:users_roles, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :role_id, references(:roles, on_delete: :delete_all)
    end

    create unique_index(:users_roles, [:user_id])
  end
end
