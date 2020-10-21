# Edit route

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