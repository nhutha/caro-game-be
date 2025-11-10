module Mutations
  class RegisterUser < BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: true
    argument :username, String, required: true

    field :access_token, String, null: true
    field :refresh_token, String, null: true
    field :user, Types::UserType, null: true

    def resolve(email: nil, password: nil, password_confirmation: nil, username: nil)
      user = User.create! email: email, password: password, password_confirmation: password_confirmation, username: username
      user.save!

      token = JwtService.new(user: user).perform

      { user: user, access_token: token[:access_token], refresh_token: token[:refresh_token] }
    end
  end
end
