defmodule PhoenixAdmin.RoleController do
  use PhoenixAdmin.Web, :controller
  alias PhoenixAdmin.Role

  plug :scrub_params, "data" when action in [:create, :update]
  plug Guardian.Plug.EnsureAuthenticated, [handler: PhoenixAdmin.ErrorHandler]

  def index(conn, _params) do
    roles = Repo.all(Role)
    render(conn, "index.json-api", data: roles)
  end

  def create(conn, %{"data" => %{"attributes" => role_params}}) do
    changeset = Role.changeset(%Role{}, role_params)

    case Repo.insert(changeset) do
      {:ok, role} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", role_path(conn, :show, role))
        |> render("show.json-api", data: role)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    role = Repo.get!(Role, id)
    render(conn, "show.json-api", data: role)
  end

  def update(conn, %{"id" => id, "data" => %{"attributes" => role_params}}) do
    role = Repo.get!(Role, id)
    changeset = Role.changeset(role, role_params)

    case Repo.update(changeset) do
      {:ok, role} ->
        render(conn, "show.json-api", data: role)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    role = Repo.get!(Role, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(role)

    send_resp(conn, :no_content, "")
  end
end
