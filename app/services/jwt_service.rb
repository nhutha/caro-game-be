# frozen_string_literal: true

# Service to generate JWT access and refresh tokens for user authentication
#
# @example Generate tokens for a user
#   tokens = JwtService.new(user: user).perform
#   # => { access_token: "...", refresh_token: "..." }
#
class JwtService
  include CreateRefreshTokenModule
  include EncodeTokenModule
  include DecodeTokenModule

  def initialize(user: nil, jti: nil)
    @user = user
    @jti = jti || generate_new_jti
  end

  # Generate access and refresh tokens
  #
  # @return [Hash] containing :access_token and :refresh_token
  def perform
    {
      access_token: encode_access_token,
      refresh_token: encode_refresh_token
    }
  end

  private

  attr_reader :user, :jti

  # Generate a new JTI (JWT ID) by creating a refresh token
  #
  # @return [String] the token identifier
  def generate_new_jti
    create_refresh_token(user).token
  end

  # Encode the access token with user_id and expiration
  #
  # @return [String] the encoded JWT access token
  def encode_access_token
    payload = {
      user_id: user.id,
      exp: Settings.user.auth.access_token.exp.hour.since.to_i,
      jti: jti
    }
    encode_token(payload)
  end

  # Encode the refresh token with JTI
  #
  # @return [String] the encoded JWT refresh token
  def encode_refresh_token
    encode_token({ jti: jti })
  end
end
