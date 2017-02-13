defmodule PhoenixAdmin.UsersRoles do
  use PhoenixAdmin.Web, :model

  @primary_key false

  schema "users_roles" do
    belongs_to :user, PhoenixAdmin.User
    belongs_to :role, PhoenixAdmin.Role
  end
end
