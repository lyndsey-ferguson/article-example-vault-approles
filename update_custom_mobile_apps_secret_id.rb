require 'vault'
require "rbnacl"
require "base64"
require 'octokit'
require 'pry-byebug'

def create_box(public_key)
  b64_key = RbNaCl::PublicKey.new(Base64.decode64(public_key[:key]))
  {
    key_id: public_key[:key_id],
    box: RbNaCl::Boxes::Sealed.from_public_key(b64_key)
  }
end

while true do
  secret = Vault.approle.create_secret_id("custom-mobile-apps-signer")
  puts secret.data[:secret_id] + "\n"
  puts "time to update the 'VAULT_CODESIGNING_ROLE_ID' secret"
  github_token = File.read('update-public-repos-token.txt')
  byebug
  github_client = Octokit::Client.new(:access_token => github_token)
  repo = github_client.repository('lyndsey-ferguson/article-example-securing-signing-assets')
  # get "#{Repository.path repo}/actions/secrets/public-key"
  box = create_box(github_client.get("#{Octokit::Repository.path(repo.id)}/actions/secrets/public-key"))
  encrypted = box[:box].encrypt(secret.data[:secret_id])
  response = github_client.put("#{repo.url}/actions/secrets/VAULT_CODESIGNING_SECRET_ID",
    encrypted_value: Base64.strict_encode64(encrypted),
    key_id: box[:key_id]
  )
  puts response
  sleep 10
end