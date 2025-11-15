# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :sign_in_user, mutation: Mutations::SignInUser
    field :register_user, mutation: Mutations::RegisterUser
    field :create_room, mutation: Mutations::CreateRoom
  end
end
