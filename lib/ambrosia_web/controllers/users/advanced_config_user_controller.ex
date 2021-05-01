defmodule AmbrosiaWeb.Users.AdvancedConfigUserController do
  use AmbrosiaWeb, :controller

  alias Ambrosia.Users.UserToken
  alias Ambrosia.Repo
  alias Pow.Ecto.Schema.Changeset, as: PowUser
  alias Pow.Plug

  def index(conn, _params) do   
    render_index_page(%{:conn => conn, :error => []})
  end

  # Call from edit profile to generate token
  def generate_token(conn, _params = %{"token" => token_form}) do
    config = Plug.fetch_config(conn)
    user = Plug.current_user(conn)

    user
    |> check_password(token_form["current_password"], config)
    |> create_token(conn, user)
    |> render_index_page()
  end

  def delete_token(conn, %{"id" => id}) do
    UserToken
    |> Repo.get_by(token: id)
    |> delete_this_token(conn)
    |> render_index_page()
  end

  def update(conn, _params = %{"user_locale" => locale}) do
    Gettext.known_locales(AmbrosiaWeb.Gettext)
    |> Enum.member?(locale)
    |> update_user_locale(conn, locale)
    |> manage_update_user_locale_error(conn)
  end

  defp update_user_locale(true, conn, locale) do
    user = Pow.Plug.current_user(conn)
    new_user = Ecto.Changeset.change user, locale: locale
    Ambrosia.Repo.update new_user
  end

  defp update_user_locale(false, _conn, locale) do
    changeset = %{
      :errors => [locale: {"Invalid locale '#{locale}'", []}]
    }
    {:error, changeset}
  end

  defp manage_update_user_locale_error({:ok, struct}, conn) do
    conn = Pow.Plug.create(conn, struct)
    render_index_page(%{:conn => conn, :error => []})
  end
  
  defp manage_update_user_locale_error({:error, changeset}, conn) do
    render_index_page(%{:conn => conn, :error => changeset.errors})
  end

  # Token not found.
  defp delete_this_token(nil, conn) do
    %{:conn => conn, :error => [token: {"token not found", [validation: :required]}]}
  end

  # Token found, delete it.
  defp delete_this_token(token, conn) do
    Repo.delete(token)
    |> delete_this_token_manage(conn)
  end

  # Manage return of delete token if error.
  defp delete_this_token_manage({:error, _}, conn) do
    %{:conn => conn, :error => [token: {"cannot delete token", [validation: :required]}]}
  end

  # Manage return of delete token if ok.
  defp delete_this_token_manage({:ok, _}, conn) do
    %{:conn => conn, :error => []}
  end

  # If password is empty, return error message
  defp check_password(_user, "", _config) do
    [current_password: {"can't be blank", [validation: :required]}]
  end

  # If error not empty, check it and return true or false
  defp check_password(user, password, config) do
    PowUser.verify_password(user, password, config)
  end

  # PowUser password is ok. Return Conn.t()
  defp create_token(true, conn, user) do
    attrs = %{
      :create_at => DateTime.utc_now(),
      :token => Pow.UUID.generate(),
      :user => user
    }

    # TODO if same UUID, error raise ! Catch it

    %UserToken{}
    |> UserToken.changeset(attrs)
    |> Repo.insert()

    %{:conn => conn, :error => []}
  end

  # PowUser password is wrong. Return error message
  defp create_token(false, conn, _user) do
    %{:conn => conn, :error => [current_password: {"is invalid", [validation: :required]}]}
  end

  # Previously we get error, return it
  defp create_token(error, conn, _user) do
    %{:conn => conn, :error => error}
  end

  # Compute number day between today and date
  defp diff_number_day_since_today(date) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.diff(date)
    |> Kernel./(3600 * 24)
    |> Kernel.trunc
  end

  defp render_index_page(_conn_and_error = %{:conn => conn, :error => error}) do
    user = Plug.current_user(conn)

    tokens = UserToken
             |> Repo.all()
             |> Enum.map(fn ut -> Map.put(ut, :since_days, diff_number_day_since_today(ut.updated_at))  end)

    render(conn, "index.html", data: %{:errors => error, :tokens => tokens}, current_locale: user.locale)
  end
end
