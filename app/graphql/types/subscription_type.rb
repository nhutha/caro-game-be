module Types
  class SubscriptionType < Types::BaseObject
    description "The subscription root for the GraphQL schema"


    # Subscribe to room creation events
    field :room_created, subscription: Subscriptions::RoomCreated
  end
end