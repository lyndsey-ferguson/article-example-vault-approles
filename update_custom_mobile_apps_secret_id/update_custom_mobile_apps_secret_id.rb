#!/usr/bin/env ruby

require 'vault'
require "rbnacl"
require "base64"
require 'octokit'

def create_box(public_key)
  b64_key = RbNaCl::PublicKey.new(Base64.decode64(public_key[:key]))
  {
    key_id: public_key[:key_id],
    box: RbNaCl::Boxes::Sealed.from_public_key(b64_key)
  }
end

github_token = File.read('update-public-repos-token.txt')

while true do
  secret = Vault.approle.create_secret_id("custom-mobile-apps-signer")
  github_client = Octokit::Client.new(:access_token => github_token)
  repo = github_client.repository('lyndsey-ferguson/article-example-securing-signing-assets')
  box = create_box(github_client.get("#{repo.url}/actions/secrets/public-key"))
  encrypted = box[:box].encrypt(secret.data[:secret_id])
  response = github_client.put("#{repo.url}/actions/secrets/VAULT_CODESIGNING_SECRET_ID",
    encrypted_value: Base64.strict_encode64(encrypted),
    key_id: box[:key_id]
  )
  sleep 2700
end