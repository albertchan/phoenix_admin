defmodule PhoenixAdmin.Router do
  use PhoenixAdmin.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json-api"]
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/", PhoenixAdmin do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # API scope
  scope "/api", PhoenixAdmin do
    pipe_through :api

    resources "/roles", RoleController, except: [:new, :edit]

    resources "/users", UserController, except: [:new, :edit]
    post "/users/login", UserController, :login
    post "/users/logout", UserController, :logout
    post "/users/register", UserController, :register
    post "/users/resend_verification", UserController, :resend_verification
    post "/users/recover_password", UserController, :recover_password
    post "/users/reset_password", UserController, :reset_password
    post "/users/verify", UserController, :verify
  end
end
