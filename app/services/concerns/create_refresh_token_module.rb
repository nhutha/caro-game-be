module CreateRefreshTokenModule
  extend ActiveSupport::Concern

  def create_refresh_token(user)
    token = generate_unique_token(user)
    expiration_at = Settings.user.auth.refresh_token.exp.hours.since

    user.refresh_tokens.create!(token:, expiration_at:)
  end

  private

  def generate_unique_token(user)
    loop do
      token = "#{user.id}_#{SecureRandom.hex(64)}_#{Time.zone.now.to_i}"
      break token unless user.refresh_tokens.exists?(token:)
    end
  end
end
