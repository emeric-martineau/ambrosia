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
