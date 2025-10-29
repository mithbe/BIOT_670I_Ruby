# restart server when you modify this file

# Filter sensitive parameters from logs to protect user data
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key,
  :crypt, :salt, :certificate, :otp, :ssn,
  :cvv, :cvc
]
