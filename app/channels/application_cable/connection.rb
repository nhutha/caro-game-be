module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags 'ActionCable', current_user.username if current_user
    end

    private

    def find_verified_user
      # Get token from query params or cookies
      token = request.params[:token] || cookies[:token]
      return nil unless token

      begin
        # Decode JWT token
        decoded = JWT.decode(token, ENV.fetch("JWT_SECRET_KEY", nil), true, { algorithm: 'HS256' })
        payload = decoded.first
        user_id = payload['user_id']

        if verified_user = User.find_by(id: user_id)
          verified_user
        else
          reject_unauthorized_connection
        end
      rescue JWT::DecodeError, JWT::ExpiredSignature
        # Allow anonymous connections for public games
        nil
      end
    end
  end
end
