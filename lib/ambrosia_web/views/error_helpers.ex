defmodule AmbrosiaWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field, f) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      f.(translate_error(error))
    end)
  end

  @doc """
  Is form has error
  """
  def has_error(form) do
    Kernel.length(form.errors) != 0
  end

  @doc """
  Check if error in form. If yes, return class and error class.
  """
  def add_class_error(form, std_class, err_class) do
    case has_error(form) do
      true -> std_class <> " " <> err_class
      false -> std_class
    end
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(AmbrosiaWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(AmbrosiaWeb.Gettext, "errors", msg, opts)
    end
  end
end
