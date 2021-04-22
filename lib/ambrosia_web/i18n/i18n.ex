defmodule AmbrosiaWeb.I18n do
  import Plug.Conn

  @moduledoc """
  A module providing Internationalization with a gettext-based API.

  Cookie key is set to "locale" by default.
  """
  defmodule Config do
    @enforce_keys [:gettext]
    defstruct [:gettext, :cookie_key]
  end

  @behaviour Plug

  @impl Plug
  def init(opts) do
    [key1, key2] = opts[:config]

    o = Application.get_env(key1, key2)
    
    struct!(Config, o)
    |> set_config_default_value()
  end

  @impl Plug
  def call(
        %{
          method: "GET"
        } = conn,
        config
      ), do: call_with_locale(conn, config)

  @impl Plug
  def call(conn, _config), do: conn

  defp set_config_default_value(%Config{cookie_key: nil} = config) do
    config
    |> struct(%{cookie_key: "locale"})
  end

  defp set_config_default_value(config), do: config

  defp call_with_locale(conn, config) do
    %{cookies: cookies} = conn
    |> fetch_cookies([encrypted: config.cookie_key])

    # Get from cookie
    cookies[config.cookie_key]
    |> set_locale(config)
    |> set_cookie(conn, config)
  end

  defp set_locale(nil, _config), do: nil

  defp set_locale(l, config) do 
    Gettext.put_locale(config.gettext, l)
    l
  end

  defp set_cookie(nil, conn, _config), do: conn

  defp set_cookie(l, conn, config) do
    conn
    |> Plug.Conn.put_resp_cookie(config.cookie_key, l, encrypt: true)
  end
end
