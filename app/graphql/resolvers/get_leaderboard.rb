# frozen_string_literal: true

module Resolvers
  class GetLeaderboard < BaseResolver
    description "Get user leaderboard sorted by points"
    
    type [Types::UserType], null: false
    
    argument :limit, Integer, required: false, default_value: 10

    def resolve(limit:)
      User.order(points: :desc, wins: :desc)
          .limit(limit)
    end
  end
end
