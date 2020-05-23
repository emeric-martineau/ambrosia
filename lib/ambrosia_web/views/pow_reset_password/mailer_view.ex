defmodule AmbrosiaWeb.PowResetPassword.MailerView do
  use AmbrosiaWeb, :mailer_view

  def subject(:reset_password, _assigns), do: "Reset password link"
end
