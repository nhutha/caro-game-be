# frozen_string_literal: true

module Mutations
  class RegisterUser < BaseMutation
    description "Register a new user account"

    argument :email, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: true
    argument :username, String, required: true

    field :access_token, String, null: true
    field :refresh_token, String, null: true
    field :user, Types::UserType, null: true

    def resolve(email:, password:, password_confirmation:, username:)
      user = create_user(email, password, password_confirmation, username)
      tokens = generate_tokens(user)

      {
        user: user,
        access_token: tokens[:access_token],
        refresh_token: tokens[:refresh_token]
      }
    end

    private

    def create_user(email, password, password_confirmation, username)
      User.create!(
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        username: username
      )
    end

    def generate_tokens(user)
      JwtService.new(user: user).perform
    end
  end
end
