class GraphqlChannel < ApplicationCable::Channel
  def subscribed
    @subscription_ids = []
  end

  def execute(data)
    query = data["query"]
    variables = ensure_hash(data["variables"])
    operation_name = data["operationName"]
    context = {
      channel: self,
      current_user: current_user, # ← Thêm current_user vào context
    }
puts "zzzz"
    result = CaroGameBeSchema.execute({
      query: query,
      context: context,
      variables: variables,
      operation_name: operation_name,
    })

    payload = {
      result: result.to_h,
      more: result.subscription?,
    }

    # Append the subscription id
    @subscription_ids << result.context[:subscription_id] if result.context[:subscription_id]

    transmit(payload)
  end

  def unsubscribed
    # Delete all of the consumer's subscriptions from the GraphQL Schema
    @subscription_ids.each do |sid|
      CaroGameBeSchema.subscriptions.delete_subscription(sid)
    end
  end

  private

  def current_user
    # Get current_user from connection (identified_by)
    connection.current_user
  end

  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end
end