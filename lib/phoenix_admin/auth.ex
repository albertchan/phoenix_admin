defmodule PhoenixAdmin.Auth do
  use PhoenixAdmin.Web, :controller

  @doc """
  Helper function to retrieve the logged in user from the session
  """
  def current_user(conn) do
    user = get_session(conn, :current_user)
	  if user, do: Repo.get!(User, user.id)
  end

  @doc """
  Generates a token for user verification or password reset purposes
  """
  def generate_token() do
    :crypto.strong_rand_bytes(24) |> Base.url_encode64
  end

  @doc """
  Generates an URL query param with a token for user verification or
  password reset purposes
  """
  def generate_token_link(user_email) do
    token = :crypto.strong_rand_bytes(24) |> Base.url_encode64
    {token, "email=#{URI.encode_www_form(user_email)}&token=#{token}"}
  end
end
