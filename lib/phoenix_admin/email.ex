defmodule PhoenixAdmin.Email do
  use Bamboo.Phoenix, view: PhoenixAdmin.EmailView

  def registration_email(user, link) do
    verify_url = "http://www.example.com/verify?#{link}"
    base_email()
    |> to(user)
    |> subject("Thank you for registering with Phoenix Admin!")
    |> assign(:user, user)
    |> render(:registration, user: user, verify_url: verify_url)
  end

  def reset_password_email(user, link) do
    reset_url = "http://www.example.com/reset_password?#{link}"
    base_email()
    |> to(user)
    |> subject("Reset password for Phoenix Admin")
    |> assign(:user, user)
    |> render(:reset_password, user: user, reset_url: reset_url)
  end

  defp base_email do
    new_email()
    |> from("no-reply@your-company.com")
    # This will use the "email.html.eex" file as a layout when rendering html emails
    # Plain text emails will not use a layout unless you use `put_text_layout`
    |> put_html_layout({PhoenixAdmin.LayoutView, "email.html"})
  end
end
