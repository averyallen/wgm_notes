require 'base64'
require 'jwt'

def pbcopy(input)
  str = input.to_s
  IO.popen('pbcopy', 'w') { |f| f << str }
  str
end

rsa_private = OpenSSL::PKey::RSA.new(File.read(File.expand_path('<path to your private key generated through Carequality workflow>')))

extra_headers = {
  'x5c': [
    '<base64-encoded DER certificate generated through Carequality workflow>'
  ]
}

payload = {
  'iss': 'cerner-test-client',
  'sub': 'fhir-ehr.stagingcerner.com',
  'aud': 'https://fhir-open.stagingcerner.com/beta/0b8a0111-e8e6-4c26-a91c-5069cbc6b1ca/Authorization/token',
  'exp': Time.now.to_i + 300,
  'jti': 'random-non-reusable-jwt-id-123'
}

authentication_jwt = JWT.encode(payload, rsa_private, 'RS256', extra_headers)
puts authentication_jwt, '', 'copied to clipboard'

pbcopy(authentication_jwt)
