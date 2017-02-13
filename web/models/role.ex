defmodule PhoenixAdmin.Role do
  use PhoenixAdmin.Web, :model

  schema "roles" do
    field :name, :string
    field :description, :string

    timestamps()

    # relationships
    many_to_many :user, PhoenixAdmin.User, join_through: "users_roles"
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description])
    |> validate_required([:name, :description])
    |> unique_constraint(:name)
  end
end
