defmodule FeeddevWeb.PowEmailConfirmation.MailerView do
  use FeeddevWeb, :mailer_view

  def subject(:email_confirmation, _assigns), do: "Confirm your email address"
end
