defmodule PhoenixAdmin.UserController do
  use PhoenixAdmin.Web, :controller
  alias PhoenixAdmin.{Auth, Email, Mailer, Repo, Role, User}
  import Comeonin.Bcrypt, only: [checkpw: 2]
  import Ecto.Changeset

  plug :scrub_params, "data" when action in [:create, :register, :update, :login]
  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixAdmin.ErrorHandler] when action in [:index, :show, :update, :delete, :logout]

  @doc """
  List all users.
  GET /api/users
  """
  def index(conn, params) do
    page = User
    |> where([u], u.id > 0)
    |> Repo.paginate(params)
    meta_data = %{ "total_entries" => page.total_entries }
    render(conn, :show, data: page, opts: [meta: meta_data])
  end

  @doc """
  Create a user with valid changeset.
  POST /api/users
  """
  def create(conn, %{"data" => %{"attributes" => user_params}}) do
    changeset = User.changeset_create(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render(:show, data: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  @doc """
  Show the user with the provide ID.
  GET /api/users/:id
  """
  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, :show, data: user)
  end

  @doc """
  Update a user with valid changeset.
  PUT /api/users/:id
  """
  def update(conn, %{"id" => id, "data" => %{"attributes" => user_params}}) do
    user = Repo.get!(User, id)
    changeset = User.changeset_update(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        render(conn, :show, data: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  @doc """
  Delete the user with the provide ID.
  DELETE /api/users/:id
  """
  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    send_resp(conn, :no_content, "")
  end

  @doc """
  Login user with valid changeset and credentials.
  POST /api/users/login
  """
  def login(conn, %{"data" => %{"attributes" => user_params}}) do
    changeset = User.changeset_login(%User{}, user_params)

    case try_login(changeset, user_params) do
      {:ok, user} ->
        claims = Guardian.Claims.app_claims
        |> Map.put("email", user.email)
        |> Map.put("name", user.name)
        |> Map.put("user_id", user.id)
        {:ok, jwt, full_claims} = Guardian.encode_and_sign(user, :access, claims)
        exp = Map.get(full_claims, "exp")

        conn
        |> put_status(:created)
        |> put_resp_header("Authorization", "Bearer #{jwt}")
        |> put_resp_header("x-expires", "#{exp}")
        |> render("login.json", jwt: jwt, exp: exp, user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
      :not_verified ->
        error = %{
          source: "/api/session",
          title: "Not verified",
          detail: "Your account has not been verified."
        }
        conn
        |> put_status(:unprocessable_entity)
        |> render(PhoenixAdmin.ErrorView, "error.json", error: error)
    end
  end

  @doc """
  Logout user with valid changeset.
  POST /api/users/logout
  """
  # http://blog.overstuffedgorilla.com/simple-guardian-api-authentication/
  # https://github.com/ylankgz/shlack/blob/master/config/config.exs
  def logout(conn, _params) do
    # jwt = Guardian.Plug.current_token(conn)
    # claims = Guardian.Plug.claims(conn)
    # case Guardian.revoke!(jwt, claims) do
    #   :ok -> render(conn, "logout.json")
    # end
    {:ok, claims} = Guardian.Plug.claims(conn)
    Guardian.Plug.current_token(conn)
    |> Guardian.revoke!(claims)
    render(conn, "logout.json", success: %{logout: true})
  end

  @doc """
  Registers a new user from a valid registration changeset.
  POST /api/users/register
  """
  def register(conn, %{"data" => %{"attributes" => %{"email" => email} = user_params}}) do
    {token, link} = Auth.generate_token_link(email)
    author_role = Repo.get_by!(Role, name: "author")
    changeset = User.changeset_registration(%User{}, user_params, token)
    |> Ecto.Changeset.put_assoc(:roles, [author_role])

    case Repo.insert(changeset) do
      {:ok, user} ->
        send_verification_email(email, link)
        conn
        |> put_status(:created)
        |> render("show.json-api", data: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  @doc """
  Resends verification email link to user.
  POST /api/users/resend_verification
  """
  def resend_verification(conn, %{"user" => %{"email" => email} = user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case changeset do
      %Ecto.Changeset{valid?: true} ->
        user = Repo.get_by(User, email: String.downcase(email))

        case user do
          nil ->
            error = %{
              source: "/api/resend_verification",
              title: "Invalid email",
              detail: "No user was found with email address."
            }
            conn
            |> put_status(:unprocessable_entity)
            |> render(PhoenixAdmin.RegistrationView, "expired.json", error: error)
          _ ->
            {token, link} = Auth.generate_token_link(user.email)
            changeset = User.changeset_verification(user, user_params, token)
            conn
            |> update_and_send(changeset, link)
        end
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  @doc """
  Sends a password reset email to user.
  POST /api/users/recover_password
  """
  def recover_password(conn, %{"data" => %{"attributes" => %{"email" => email}} = user_params}) do
    {token, link} = Auth.generate_token_link(email)
    changeset = User.changeset_reset(%User{}, user_params["attributes"], token)

    case changeset do
      %Ecto.Changeset{valid?: true} ->
        user = Repo.get_by(User, email: String.downcase(email))

        case user do
          nil ->
            error = %{
              source: %{"pointer": "/data/attributes/email"},
              title: "Invalid attribute",
              detail: "No user was found with email address."
            }
            conn
            |> put_status(:unprocessable_entity)
            |> render(PhoenixAdmin.ErrorView, "error.json", error: error)
          _ ->
            changeset = User.changeset_reset(user, user_params, token)
            conn
            |> update_and_send_reset(changeset, link)
        end
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  @doc """
  Reset user password if valid token is provided.
  POST /api/users/reset_password
  """
  def reset_password(conn, %{"data" => %{"attributes" => %{"password" => new_password, "token" => reset_token}}}) do
    user = Repo.get_by(PhoenixAdmin.User, reset_token: reset_token)
    reset_password(conn, user, new_password)
  end

  @doc """
  Verifies a new user from the verification email link.
  GET /api/users/verify
  """
  def verify(conn, %{"email" => email, "token" => token}) do
    user = User.find_user_by_email(email)
    case check_verification(user, token) do
      true ->
        User.put_verified_at(user)
        conn
        |> put_status(200)
        |> render("show.json-api", data: user)
      false ->
        error = %{
          source: %{"pointer": "/data/attributes/token"},
          title: "Invalid attribute",
          detail: "The verification link has expired."
        }
        conn
        |> put_status(:gone)
        |> render(PhoenixAdmin.ErrorView, "error.json", error: error)
    end
  end

  defp change_password(conn, true, _, _) do
    error = %{
      source: %{"pointer": "/data/attributes/token"},
      title: "Invalid attribute",
      detail: "The reset password token has expired."
    }
    conn
    |> put_status(:forbidden)
    |> render(PhoenixAdmin.ErrorView, "error.json", error: error)
  end
  defp change_password(conn, false, user, password) do
    changeset = User.changeset_password(user, %{password: password})
    case User.put_encrypted_password(changeset) do
      %Ecto.Changeset{valid?: true} ->
        conn
        |> put_status(200)
        |> render(:show, data: user)
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  defp check_password(user, password) do
    case user do
      nil -> false
      _ -> checkpw(password, user.encrypted_password)
    end
  end

  defp check_verification(user, token) do
    is_expired = User.check_expiry(user.verification_sent_at, 900)
    (token == user.verification_token) && !is_expired
  end

  defp do_login(user, password) do
    case user.verified_at do
      nil ->
        :not_verified
      _ ->
        case check_password(user, password) do
          true ->
            {:ok, user}
          _ ->
            {:error, login_failed()}
        end
    end
  end

  defp login_failed() do
    _changeset = User.changeset_login(%User{})
    |> add_error(:email, "Email or password is invalid")
    |> add_error(:password, "Email or password is invalid.")
  end

  defp reset_password(conn, nil, _) do
    error = %{
      source: %{"pointer": "/data/attributes/token"},
      title: "Invalid attribute",
      detail: "The reset password token is invalid."
    }
    conn
    |> put_status(:forbidden)
    |> render(PhoenixAdmin.ErrorView, "error.json", error: error)
  end
  defp reset_password(conn, user, new_password) do
    # token expires in 15 minutes
    is_expired = User.check_expiry(user.reset_sent_at, 900)
    change_password(conn, is_expired, user, new_password)
  end

  defp send_reset_email(user_email, link) do
    Email.reset_password_email(user_email, link) |> Mailer.deliver_now
  end

  defp send_verification_email(user_email, link) do
    Email.registration_email(user_email, link) |> Mailer.deliver_now
  end

  defp try_login(changeset, params) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        user = Repo.get_by(User, email: String.downcase(params["email"]))

        if user do
          do_login(user, params["password"])
        else
          {:error, login_failed()}
        end
      _ ->
        {:error, login_failed()}
    end
  end

  defp update_and_send(conn, changeset, link) do
    case Repo.update(changeset) do
      {:ok, user} ->
        send_verification_email(user.email, link)
        conn
        |> put_status(200)
        |> render(:show, data: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  defp update_and_send_reset(conn, changeset, link) do
    case Repo.update(changeset) do
      {:ok, user} ->
        send_reset_email(user.email, link)
        conn
        |> put_status(200)
        |> render(:show, data: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end
end
