module DecodeTokenModule
  extend ActiveSupport::Concern

  def decode_token(token)
    JWT.decode(token, ENV.fetch("JWT_SECRET_KEY", nil), true, { algorithm: "HS256" })
  end
end
