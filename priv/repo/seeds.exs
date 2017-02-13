# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PhoenixAdmin.Repo.insert!(%PhoenixAdmin.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PhoenixAdmin.{Repo, Role, User}

defmodule PhoenixAdmin.UserSeeder do
  def create(params) do
    super_admin_role = Repo.get_by!(Role, name: "super_admin")
    token = :crypto.strong_rand_bytes(24) |> Base.url_encode64

    Repo.transaction fn ->
      _changeset = User.changeset_registration(%User{}, params, token)
      |> Ecto.Changeset.put_assoc(:roles, [super_admin_role])
      |> Ecto.Changeset.put_change(:verified_at, Ecto.DateTime.utc)
      |> Repo.insert
    end
  end
end

# Create default user roles for the system. Note the order in which
# the roles are created is important! Specifically, the "super_admin" role
# must be created first as its id must be equal to 1
[
  %Role{
    name: "super_admin",
    description: "Super Admin role"
  },
  %Role{
    name: "admin",
    description: "Administrator role"
  },
  %Role{
    name: "editor",
    description: "Editor role"
  },
  %Role{
    name: "author",
    description: "Author role"
  }
] |> Enum.each(&Repo.insert!(&1))

# create the default admin user
PhoenixAdmin.UserSeeder.create(%{
  email: "admin@example.com",
  name: "Super Administrator",
  password: "test123456",
  password_confirmation: "test123456",
})
