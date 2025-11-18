# frozen_string_literal: true

module Mutations
  class SignInUser < BaseMutation
    description "Sign in a user with email and password"

    null true

    argument :email, String, required: true
    argument :password, String, required: true

    field :access_token, String, null: true
    field :refresh_token, String, null: true
    field :user, Types::UserType, null: true

    def resolve(email:, password:)
      user = authenticate_user(email, password)
      tokens = generate_tokens(user)

      {
        user: user,
        access_token: tokens[:access_token],
        refresh_token: tokens[:refresh_token]
      }
    end

    private

    def authenticate_user(email, password)
      user = User.find_by(email: email)

      unless user&.authenticate(password)
        raise Error::UnauthorizedError.new("Invalid email or password")
      end

      user
    end

    def generate_tokens(user)
      JwtService.new(user: user).perform
    end
  end
end
