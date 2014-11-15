class ClientController < ApplicationController
  def new
    @slider_vars = {
      turnDuration: 5000,
      preventDoubleInputDelay: 100,
      waitAfterInputBeforeTurnEndDelay: 200,
      animationDuration: 100
    }
  end
end
