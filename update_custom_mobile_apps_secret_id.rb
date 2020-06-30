require 'vault'

while true do
  secret = Vault.approle.create_secret_id("custom-mobile-apps-signer")
  print secret.data[:secret_id] + "\n"
  sleep 10
end