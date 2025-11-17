# frozen_string_literal: true

module Types
  class MoveType < Types::BaseObject
    field :id, ID, null: false
    field :game, Types::GameType, null: false
    field :user, Types::UserType, null: false
    field :row, Integer, null: false
    field :col, Integer, null: false
    field :symbol, String, null: false
    field :turn_number, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
