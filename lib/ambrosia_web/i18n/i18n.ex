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
    conn
    |> get_locale_from_user(config)
    |> get_locale_from_cookie(conn, config)
    |> get_locale_from_request_header(conn, config)
    |> set_locale(conn, config)
  end

  defp set_locale(nil, conn, _config), do: conn

  defp set_locale(lang, conn, config) do
    Gettext.put_locale(config.gettext, lang)
    conn
  end

  defp get_locale_from_user(conn, config) do
    # TODO
    nil
  end

  defp get_locale_from_cookie(nil, conn, config) do
    %{cookies: cookies} = conn
    |> fetch_cookies()

    cookies[config.cookie_key]
  end

  defp get_locale_from_cookie(lang, _conn, _config), do: lang

  # Get header
  # {"accept-language", "fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"}
  defp get_locale_from_request_header(nil, conn, _config) do
    conn
    |> Plug.Conn.get_req_header("accept-language")
    |> extract_language_from_header()
    |> find_first_available_language()
  end

  defp get_locale_from_request_header(lang, _conn, _config), do: lang

  defp extract_language_from_header(nil), do: nil

  defp extract_language_from_header([]), do: nil

  # Plug.Conn.get_req_header return a list like
  # ["fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7"]
  #
  # Accept-Language: <langue>        -> en
  # Accept-Language: <locale>        -> fr-FR
  # Accept-Language: *
  #
  # Multi type:
  # Accept-Language: fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5
  defp extract_language_from_header([lang | _]), do: String.split(lang, ",", trim: true)
  
  defp find_first_available_language(nil), do: nil

  defp find_first_available_language([]), do: nil

  defp find_first_available_language([item | list]) do
    [lang | _] = String.split(item, ";", trim: false)

    Gettext.known_locales(AmbrosiaWeb.Gettext)
    |> Enum.member?(lang)
    |> case do
         true -> lang
         false -> find_first_available_language(list)
       end
  end
end
