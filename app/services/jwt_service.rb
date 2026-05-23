# app/services/jwt_service.rb
module JwtService
  SECRET_KEY = Rails.application.secret_key_base
  EXPIRY     = 24.hours.from_now

  def self.encode(payload)
    payload[:exp] = EXPIRY.to_i
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })
    HashWithIndifferentAccess.new(decoded.first)
  rescue JWT::ExpiredSignature
    raise AuthenticationError, "Token has expired. Please log in again."
  rescue JWT::DecodeError
    raise AuthenticationError, "Invalid token."
  end
end
