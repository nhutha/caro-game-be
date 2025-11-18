# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    description "A user/player in the game"

    # Core fields
    field :id, ID, null: false
    field :username, String, null: false
    field :email, String, null: false

    # Statistics
    field :wins, Integer, null: false
    field :losses, Integer, null: false
    field :draws, Integer, null: false
    field :points, Integer, null: false

    # Computed statistics
    field :total_games, Integer, null: false
    field :win_rate, Float, null: false

    # Timestamps
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
