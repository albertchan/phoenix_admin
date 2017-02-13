defmodule PhoenixAdmin.UserView do
  use PhoenixAdmin.Web, :view

  attributes [:email, :name, :verified_at]

  def render("login.json", %{jwt: jwt, exp: exp, user: user}) do
    %{"token": jwt,
      "expiry": exp,
      "user": %{
        id: user.id,
        displayName: user.name
      }
    }
  end

  def render("logout.json", %{success: success}) do
    %{"logout": success.logout}
  end
end
