# Edit route

All routes are stored in `lib/ambrosia_web/router.ex` file.

## Pipelines

You have 5 predefined pipelines.

### :browser

The `:browser` pipeline allow browser to get this route.

Contente type returned is HTML, it's protected against some classic attack.

### :api

The `:api` pipeline accept and return only json format.

### :admin_layout

The `:admin_layout` pipeline add all layout when user are connected.

### :protected

The `:protected` pipeline force user to be connected to get HTML content.

### :api_protected

The `:api_proteted` pipeline force user to send basic auth or token in request header to get json content.

## Pow rewrite url

Some Pow url has been change to be more clear for end user. This is happend in `lib/ambrosia_web/router.ex` file:
```
  scope "/", Pow.Phoenix, as: "pow" do
    pipe_through :browser

    get "/profile/edit", RegistrationController, :edit
    patch "/profile/edit", RegistrationController, :update
    put "/profile/edit", RegistrationController, :update

    get "/profile/login", SessionController, :new
    post "/profile/login", SessionController, :create
    delete "/profile/logout", SessionController, :delete
  end
```

Path template are not changed:
 - `lib/ambrosia_web/templates/pow/session/new.html.eex` for `/profile/login`,
 - `lib/ambrosia_web/templates/pow/registration/edit.html.eex` for `/profile/edit`

# Update locale

Ambrosia use [Elixir gettext](https://github.com/elixir-gettext/gettext). When you add a new item in source code, just run:
```
$ mix gettext.extract
Extracted priv/gettext/menu.pot
Extracted priv/gettext/profile.pot

$ mix gettext.merge priv/gettext
Wrote priv/gettext/en/LC_MESSAGES/default.po (0 new translations, 0 removed, 1 unchanged, 0 reworded (fuzzy))
Wrote priv/gettext/en/LC_MESSAGES/menu.po (0 new translations, 0 removed, 4 unchanged, 0 reworded (fuzzy))
Wrote priv/gettext/en/LC_MESSAGES/errors.po (0 new translations, 0 removed, 24 unchanged, 0 reworded (fuzzy))
Wrote priv/gettext/en/LC_MESSAGES/profile.po (1 new translation, 0 removed, 28 unchanged, 0 reworded (fuzzy))
Wrote priv/gettext/fr/LC_MESSAGES/default.po (1 new translation, 1 removed, 0 unchanged, 0 reworded (fuzzy))
Wrote priv/gettext/fr/LC_MESSAGES/menu.po (0 new translations, 0 removed, 4 unchanged, 0 reworded (fuzzy))
Wrote priv/gettext/fr/LC_MESSAGES/errors.po (0 new translations, 1 removed, 23 unchanged, 1 reworded (fuzzy))
Wrote priv/gettext/fr/LC_MESSAGES/profile.po (1 new translation, 0 removed, 28 unchanged, 0 reworded (fuzzy))
```
## Add new lang

Edit `config/config.exs` file and add new locale:
```
# Internationalization
config :ambrosia, AmbrosiaWeb.Gettext, default_locale: "en", locales: ~w(en fr)
```

After, add in `lib/ambrosia_web/templates/layout/_locales_list.eex` menu file
