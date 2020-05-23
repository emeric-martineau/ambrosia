defmodule AmbrosiaWeb.PowEmailConfirmation.MailerView do
  use AmbrosiaWeb, :mailer_view

  def subject(:email_confirmation, _assigns), do: "Confirm your email address"
end
