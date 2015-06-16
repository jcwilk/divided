class Move < Hashie::Dash
  property :player_uuid, required: true
  property :x, required: true
  property :y, required: true
  property :id, required: true
  property :round_id, required: true
  property :action, required: true

  def valid?
    x >= 0 && x <= 9 &&
    y >= 0 && y <= 9
  end
end
