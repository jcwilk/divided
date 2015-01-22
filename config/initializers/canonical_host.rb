module Divided
  CANONICAL_HOST = if Rails.env.test?
      'example.com:80'
    elsif Rails.env.development?
      'localhost:3000'
    else
      #TODO: figure out why this needs a port
      # it defaults to 0 otherwise for some reason
      'divided.herokuapp.com:80' #TODO: make this an env var
    end
end
