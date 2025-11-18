# frozen_string_literal: true

module Resolvers
  class GetGameHistory < BaseResolver
    description "Get game history for a user"

    type [ Types::GameType ], null: false

    argument :user_id, ID, required: false

    def resolve(user_id: nil)
      target_user = find_target_user(user_id)
      fetch_game_history(target_user)
    end

    private

    def find_target_user(user_id)
      if user_id
        User.find(user_id)
      else
        require_authentication!
        current_user
      end
    end

    def fetch_game_history(user)
      Game.where("player_1_id = ? OR player_2_id = ?", user.id, user.id)
          .where(status: :finished)
          .order(finished_at: :desc)
          .limit(20)
    end
  end
end
