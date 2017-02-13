defmodule PhoenixAdmin.ErrorHandler do
  use PhoenixAdmin.Web, :controller

  def unauthenticated(conn, _params) do
    error = %{
      source: %{"pointer": "/data/attributes/token"},
      title: "Unauthenticated",
      detail: "Authentication required."
    }
    conn
    |> put_status(:unauthorized)
    |> render(PhoenixAdmin.ErrorView, "error.json", error: error)
  end

  def unauthorized(conn, _params) do
    error = %{
      source: %{"pointer": "/data/attributes/token"},
      title: "Unauthorized",
      detail: "Authorization required."
    }
    conn
    |> put_status(:unauthorized)
    |> render(PhoenixAdmin.ErrorView, "error.json", error: error)
  end

  def no_resource(conn, _params) do
    error = %{
      source: %{"pointer": "/data/attributes/token"},
      title: "Unauthorized",
      detail: "No resource found."
    }
    conn
    |> put_status(:unauthorized)
    |> render(PhoenixAdmin.ErrorView, "error.json", error: error)
  end

  def already_authenticated(conn, _params) do
    conn |> halt
  end
end
