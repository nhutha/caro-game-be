class JwtService
  include CreateRefreshTokenModule
  include EncodeTokenModule
  include DecodeTokenModule

  def initialize user: nil, jti: nil
    @user = user
    @jti = jti || gen_new_jti
  end

  def perform
    {
      access_token: encode_access_token,
      refresh_token: encode_token({jti:})
    }
  end

  private
  attr_reader :user, :jti

  def gen_new_jti
    create_refresh_token(user).token
  end

  def encode_access_token
    payload = {user_id: user.id, exp: Settings.user.auth.access_token.exp.hour.since.to_i, jti:}
    encode_token payload
  end
end