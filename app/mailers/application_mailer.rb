class ApplicationMailer < ActionMailer::Base
  # Set a default "from" email for all emails sent from this app
  default from: "from@example.com"

  # Use the "mailer" layout for all emails
  layout "mailer"
end
