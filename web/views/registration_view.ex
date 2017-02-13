defmodule PhoenixAdmin.RegistrationView do
  use PhoenixAdmin.Web, :view

  attributes [:email, :name]

  def render("expired.json", %{error: error}) do
    errors = %{
      source: error.source,
      title: error.title,
      detail: error.detail
    }

    %{errors: errors}
  end
end
