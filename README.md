# Ambrosia

Ambrosia is an Open-Source Full-Stack solution that helps you to build fast and maintainable web applications using
[Phoenix](https://www.phoenixframework.org), [Ecto](https://github.com/elixir-ecto/ecto), [Pow](https://powauth.com),
[PostgreSQL](https://www.postgresql.org), [Elixir](https://elixir-lang.org), [Erlang](https://www.erlang.org)...

The goal of this project is to provide a powerful and well configured stack to start new project and help you to focus
on writing your web application very quickly.

As this project is a template project and not a CLI, you have access to the entire app configuration so you can change
it according to your needs.

## Installation

Before start, you need install:
 * Erlang 20 or later
 * Elixir 1.7 or later (see [Install](https://elixir-lang.org/install.html))
 * PostgreSQL 10 or later
 * NodeJS 8 or later

Then clone this project. Use tag to select right version.

Go to root project directory and run `mix deps.get` then `mix deps.compile`:
```
$ mix deps.get
Resolving Hex dependencies...
Dependency resolution completed:
Unchanged:
  connection 1.0.4
  cowboy 2.7.0
  cowlib 2.8.0
...
```
then run `npm install --prefix "assets"` and finally goto `assets/semantic` and run `npx gulp build`.

Now return to root project path, edit `config/dev.exs` file and set database name and credential of database:
```
  username: "ambrosia",
  password: "password",
  database: "ambrosia_dev",
  hostname: "localhost",
```

## Run

If you don't have create user into database:
```
$ su postgres
# Create cluste of posgres
$ pg_createcluster -d /data/postgres/ 12 local_dev
# Créer database
$ createdb ambrosia_dev
$ psql -s ambrosia_dev
$ alter user postgres password 'postgres';

# If you use another power user that postgres:
# GRANT ALL PRIVILEGES ON DATABASE ambrosia_dev TO <my_user>;
```

Now in the same folder, setup the project with running `mix setup` and running `mix phx.server` and say yes when
prompted:
```
$ mix phx.server
==> file_system
Compiling 7 files (.ex)
Generated file_system app
==> connection
Compiling 1 file (.ex)
Generated connection app
==> gettext
Compiling 1 file (.yrl)
Compiling 1 file (.erl)
Compiling 20 files (.ex)
Generated gettext app
==> ambrosia
Could not find "rebar3", which is needed to build dependency :ranch
I can install a local copy which is just used by Mix
Shall I install rebar3? (if running non-interactively, use "mix local.rebar --force") [Yn]

...

Generated ambrosia app
[info] Running AmbrosiaWeb.Endpoint with cowboy 2.7.0 at 0.0.0.0:4000 (http)
[info] Access AmbrosiaWeb.Endpoint at http://localhost:4000

webpack is watching the files…

Browserslist: caniuse-lite is outdated. Please run next command `npm update`
Hash: a48891e43b0053b7a056
Version: webpack 4.4.0

...

Child mini-css-extract-plugin node_modules/css-loader/dist/cjs.js!css/app.css:
    Entrypoint mini-css-extract-plugin = *
    [./node_modules/css-loader/dist/cjs.js!./css/app.css] 2.29 KiB {mini-css-extract-plugin} [built]
    [./node_modules/css-loader/dist/cjs.js!./css/phoenix.css] 682 bytes {mini-css-extract-plugin} [built]
    [./node_modules/css-loader/dist/cjs.js!./css/popup.css] 234 bytes {mini-css-extract-plugin} [built]
        + 1 hidden module
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Add API

First, goto `lib/ambrosia/api/` folder and copy `survey.ex` file in same directory, change `Ambrosia.Api.Survey` to put
your namespace.

Change tablename and fieldname. See [Ecto.Changeset ](https://hexdocs.pm/ecto/Ecto.Changeset.html) for more information.

Duplicate controller `lib/ambrosia_web/controllers/api/v1/survey_controller.ex` in same folder.

Duplication view `lib/ambrosia_web/views/survey_view.ex` in same folder.

Add entry in router `lib/ambrosia_web/router.ex` in section below:
```
scope "/api/v1", AmbrosiaWeb do
  pipe_through [:api, :api_protected]

  resources "/survey", SurveyController
end
```

## Fomantic UI

Fomantic UI module is in `assets` folder. You found the standard node project. Edit `assets/semantic.json` file to
setup Fomantic UI install.

Becarefull, if you want change folder of Fomantic UI, change webpack config file `assets/webpack.config.js`:
```
new CopyWebpackPlugin([{ from: 'semantic/dist/semantic.min.css', to: '../css/' }]),
new CopyWebpackPlugin([{ from: 'semantic/dist/themes/default', to: '../css/themes/default' }]),
new CopyWebpackPlugin([{ from: 'semantic/dist/semantic.min.js', to: '../js/' }])
```

### Update

To update Fomantic UI, please edit `assets/package.json` and update `"fomantic-ui": "^2.8.7"` line.

### Set theme

To setup a new theme, please read official Fomantic UI documentation
[Theming ](https://fomantic-ui.com/usage/theming.html).

## Replace mock email

By default, no email send. All email are display in log console.

If you want send email, please add dependency like [Bamboo](https://github.com/thoughtbot/bamboo) then edit
`lib/pow/mailer.ex` file and put something like:
```
defmodule AmbrosiaWeb.Mailer do
  use Pow.Phoenix.Mailer
  use Bamboo.Mailer, otp_app: :ambrosia
  require Logger

  import Bamboo.Email

  def cast(%{user: user, subject: subject, text: text, html: html}) do
    new_email()
    |> to(user.email)
    |> from("team@example.com")
    |> subject(subject)
    |> html_body(html)
    |> text_body(text)
  end

  def process(email) do
    deliver_now(email)
  end
end
```

## Enable/Disable token auth

TODO

## Create your project

Ok, you find this project great and you want use it? Just run:
```
MY_PROJECT_NAME=<my project name>
MY_PROJECT_NAME_LOWERCASE=$(echo ${MY_PROJECT_NAME} | tr '[:upper:]' '[:lower:]')

rm -rf .git
rm -rf deps
rm -rf assets/node_modules
rm -rf _build

find -type f -print0 | xargs -0 sed -i 's/Ambrosia/'${MY_PROJECT_NAME}'/g'
find -type f -print0 | xargs -0 sed -i 's/ambrosia/'${MY_PROJECT_NAME_LOWERCASE}'/g'
mv lib/ambrosia lib/${MY_PROJECT_NAME_LOWERCASE}
mv lib/ambrosia_web lib/${MY_PROJECT_NAME_LOWERCASE}_web
mv lib/ambrosia.ex lib/${MY_PROJECT_NAME_LOWERCASE}.ex
mv lib/ambrosia_web.ex lib/${MY_PROJECT_NAME_LOWERCASE}_web.ex
```

## Ready for production?

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

### Learn more

  * [Ambrosia documentation](./DOCUMENTATION.md)
  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## License

This project is [MIT](./LICENSE.md) licensed.
