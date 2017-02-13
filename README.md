# PhoenixAdmin

Features:

* [Guardian](https://github.com/ueberauth/guardian) authentication framework
* [JSON API](http://jsonapi.org/) responses with [JaSerializer](https://github.com/vt-elixir/ja_serializer)

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Database setup

```
CREATE USER phoenix WITH PASSWORD 'verysecret';
ALTER ROLE phoenix SET client_encoding TO 'utf8';
ALTER USER phoenix CREATEDB;
```

Create the development database:

```
mix ecto.create
```

Modify `config/dev.exs` and `config/test.exs` to have the proper credentials.

```
# Configure your database
config :phoenix_admin, PhoenixAdmin.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "phoenix",
  password: "verysecret",
  database: "phoenix_admin_dev",
  hostname: "localhost",
  pool_size: 10
```

Run migrations:

```
mix ecto.migrate
```

Run seeds:

```
mix run priv/repo/seeds.exs
```

For help on other Ecto specific mix tasks, run:

```
mix help | grep -i ecto
```

## Running

Run the Phoenix application:

```
cd phoenix_admin
mix phoenix.server
```

You can also run your app inside IEx (Interactive Elixir) as:

```
iex -S mix phoenix.server
```

Test API example:

```
curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{"user":{"email":"user@example.com"}}' http://localhost:4000/api/register
```

## Tasks

[Generate a Phoenix resource](https://hexdocs.pm/phoenix/Mix.Tasks.Phoenix.Gen.Json.html)
example:

```
mix phoenix.gen.json Role roles name:string description:string
mix phoenix.gen.json User users email:string name:string encrypted_password:string
```

Generate a database migration:

```
mix ecto.gen.migration create_some_table
```

List dependencies:

```
mix deps
```

Update dependencies:

```
# Update all dependencies
mix deps.udate --all

# Update individual package
mix deps.update <package>
```

## Tests

To run tests:

```
mix test
```

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
