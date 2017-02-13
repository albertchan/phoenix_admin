defmodule PhoenixAdmin.ControllerTestHelpers do
  alias PhoenixAdmin.{Repo, Role, User}

  def insert_role(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Test Role",
      description: "Test role description"
      }, attrs)

    %Role{}
    |> Role.changeset(changes)
    |> Repo.insert
  end

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Test User",
      email: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@example.com",
      password: "supersecret",
      password_confirmation: "supersecret"
      }, attrs)

    %User{}
    |> User.changeset_registration(changes)
    |> Repo.insert!
  end

  def insert_verified_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Test User",
      email: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@example.com",
      password: "supersecret",
      password_confirmation: "supersecret",
      verified_at: Ecto.DateTime.utc
      }, attrs)

    %User{}
    |> User.changeset_registration(changes)
    |> Repo.insert!
  end
end
