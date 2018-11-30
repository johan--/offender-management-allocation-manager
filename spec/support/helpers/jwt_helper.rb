module JWTHelper
  def generate_jwt_token(options = {})
    payload = {
      'internal_user': false,
      'scope': %w[read write],
      'exp': 4.hours.from_now.to_i,
      'client_id': 'offender-management-allocation-manager'
    }.merge(options)

    rsa_private = OpenSSL::PKey::RSA.generate 2048
    rsa_public = rsa_private.public_key.to_s
    Rails.configuration.nomis_oauth_public_key = rsa_public

    JWT.encode payload, rsa_private, 'RS256'
  end
end