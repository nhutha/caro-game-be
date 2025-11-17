# frozen_string_literal: true

module Resolvers
  class GetGameHistory < BaseResolver
    description "Get game history for a user"
    
    type [Types::GameType], null: false
    
    argument :user_id, ID, required: false

    def resolve(user_id: nil)
      user = user_id ? User.find(user_id) : current_user
      require_authentication! unless user
      
      Game.where('player_1_id = ? OR player_2_id = ?', user.id, user.id)
          .where(status: :finished)
          .order(finished_at: :desc)
          .limit(20)
    end
  end
end
