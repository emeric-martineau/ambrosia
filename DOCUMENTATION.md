# Edit route

All routes are stored in `lib/ambrosia_web/router.ex` file.

## Pipelines

You have 5 predefined pipelines.

### :browser

The `:brower` pipeline allow browser to get this route.

Contente type returned is HTML, it's protected against some classic attack.

### :api

The `:api` pipeline accept and return only json format.

### :admin_layout

The `:admin_layout` pipeline add all layout when user are connected.

### :protected

The `:protected` pipeline force user to be connected to get HTML content.

### :api_protected

The `:api_proteted` pipeline force user to send basic auth or token in request header to get json content.
