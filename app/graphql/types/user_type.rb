# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :username, String, null: false
    field :email, String, null: false
    field :wins, Integer, null: false
    field :losses, Integer, null: false
    field :draws, Integer, null: false
    field :points, Integer, null: false
    field :total_games, Integer, null: false
    field :win_rate, Float, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    
    def total_games
      object.total_games
    end
    
    def win_rate
      object.win_rate
    end
  end
end
