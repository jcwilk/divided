module Divided
  #TODO: make env var mandatory for prod...?
  CANONICAL_HOST = ENV['CANONICAL_HOST'] || if Rails.env.test?
      'example.com:80'
    elsif Rails.env.development?
      'localhost:3000'
    else
      #TODO: figure out why this needs a port
      # it defaults to 0 otherwise for some reason
      'divided.herokuapp.com:80'
    end
end
