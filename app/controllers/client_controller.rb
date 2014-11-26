class ClientController < ApplicationController
  def new
    @slider_vars = {
      #turnDuration: 5000,
      preventDoubleInputDelay: 180,
      waitAfterInputBeforeTurnEndDelay: 200,
      animationDuration: 100
    }
    @player_uuid = SecureRandom.urlsafe_base64(8)
  end
end
