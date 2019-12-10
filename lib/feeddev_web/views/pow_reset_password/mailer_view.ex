defmodule FeeddevWeb.PowResetPassword.MailerView do
  use FeeddevWeb, :mailer_view

  def subject(:reset_password, _assigns), do: "Reset password link"
end
