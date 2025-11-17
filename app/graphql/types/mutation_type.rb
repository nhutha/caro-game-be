# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :sign_in_user, mutation: Mutations::SignInUser
    field :register_user, mutation: Mutations::RegisterUser
    field :create_room, mutation: Mutations::CreateRoom
    field :join_room, mutation: Mutations::JoinRoom
    field :start_game, mutation: Mutations::StartGame
    field :make_move, mutation: Mutations::MakeMove
    field :forfeit_game, mutation: Mutations::ForfeitGame
  end
end
