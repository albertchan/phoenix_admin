defmodule PhoenixAdmin.User do
  use PhoenixAdmin.Web, :model
  use Ecto.Schema
  alias PhoenixAdmin.Repo
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :last_login, Ecto.DateTime
    field :verified_at, Ecto.DateTime
    field :verification_sent_at, Ecto.DateTime
    field :verification_token, :string
    field :reset_sent_at, Ecto.DateTime
    field :reset_token, :string

    timestamps()

    # relationships
    many_to_many :roles, PhoenixAdmin.Role, join_through: "users_roles"
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :name])
    |> validate_required([:email])
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset_create(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :name, :password])
    |> validate_required([:email, :name, :password])
    |> put_encrypted_password()
  end

  @doc """
  Builds a user changeset for login.
  """
  def changeset_login(model, params \\ %{}) do
    model
    |> cast(params, [:email, :password])
    |> validate_required([:email, :password])
  end

  @doc """
  Builds a user changeset for resetting password.
  """
  def changeset_password(model, params \\ %{}) do
    model
    |> cast(params, [:password])
    |> validate_required([:password])
  end

  @doc """
  Builds a user changeset for user registration.
  """
  def changeset_registration(model, params \\ %{}, token \\ "verysecret") do
    model
    |> cast(params, [:email, :name, :password, :password_confirmation])
    |> validate_required([:email, :name, :password, :password_confirmation])
    |> unique_constraint(:email)
    |> validate_length(:password, min: 6, max: 100)
    |> validate_length(:password_confirmation, min: 6, max: 100)
    |> validate_confirmation(:password, message: "does not match password!")
    |> put_encrypted_password()
    |> put_verification_token(token)
  end

  @doc """
  Builds a user changeset for resetting password.
  """
  def changeset_reset(model, params \\ %{}, token) do
    model
    |> changeset(params)
    |> put_reset_token(token)
  end

  @doc """
  Builds a user changeset for verifying a new user.
  """
  def changeset_verification(model, params \\ %{}, token) do
    model
    |> changeset(params)
    |> put_verification_token(token)
  end

  @doc """
  Function used to check if a token has expired.
  """
  def check_expiry(nil, _), do: false
  def check_expiry(sent_at, valid_seconds) do
    (sent_at |> Ecto.DateTime.to_erl |> :calendar.datetime_to_gregorian_seconds) + valid_seconds <
      (:calendar.universal_time |> :calendar.datetime_to_gregorian_seconds)
  end

  @doc """
  Find the user, using the user id, in the database.
  """
  def find_user_by_id(id) do
    Repo.get(User, id)
  end

  @doc """
  Find the user by email in the database.
  """
  def find_user_by_email(email) do
      Repo.get_by(PhoenixAdmin.User, email: email)
  end

  def put_encrypted_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :encrypted_password, hashpwsalt(password))
      _ ->
        changeset
    end
  end

  @doc """
  Change the `verified_at` value in the database to the current time.
  """
  def put_verified_at(user) do
    change(user, %{verified_at: Ecto.DateTime.utc})
    |> Repo.update
  end

  defp put_reset_token(changeset, token) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        changeset
        |> put_change(:reset_token, token)
        |> put_change(:reset_sent_at, Ecto.DateTime.utc)
      _ ->
        changeset
    end
  end

  defp put_verification_token(changeset, token) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        changeset
        |> put_change(:verified_at, nil)
        |> put_change(:verification_token, token)
        |> put_change(:verification_sent_at, Ecto.DateTime.utc)
      _ ->
        changeset
    end
  end
end
