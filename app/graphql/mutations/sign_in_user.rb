module Mutations
  class SignInUser < BaseMutation
    null true

    argument :email, String, required: true
    argument :password, String, required: true

    field :access_token, String, null: true
    field :refresh_token, String, null: true
    field :user, Types::UserType, null: true

    def resolve(email: nil, password: nil)
      user = User.find_by(email: email)
      raise Error::UnauthorizedError.new("Invalid email or password")if !user&.authenticate(password)

      token = JwtService.new(user: user).perform

      { user: user, access_token: token[:access_token], refresh_token: token[:refresh_token] }
    end
  end
end