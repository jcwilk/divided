module Divided
  CANONICAL_HOST = if Rails.env.test?
      'example.com'
    elsif Rails.env.development?
      'localhost:3000'
    else
      'divided.herokuapp.com' #TODO: make this an env var
    end
end
