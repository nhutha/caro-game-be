module EncodeTokenModule
  extend ActiveSupport::Concern

  def encode_token payload
    JWT.encode(payload, ENV.fetch("JWT_SECRET_KEY", nil), 'HS256')
  end
end