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
      current_user: current_user,
    }

    result = CaroGameBeSchema.execute(
      query,
      context: context,
      variables: variables,
      operation_name: operation_name,
    )

    payload = {
      result: result.to_h,
      more: result.subscription?,
    }
    if result.context[:subscription_id]
      @subscription_ids << result.context[:subscription_id]
    end

    transmit(payload)
  end

  def unsubscribed
    @subscription_ids.each do |sid|
      CaroGameBeSchema.subscriptions.delete_subscription(sid)
      Rails.logger.info "   ❌ Deleted subscription: #{sid}"
    end
  end

  private

  def current_user
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