module DV
  class Root < Grape::API
    format :json
    formatter :json, Grape::Formatter::Roar

    desc 'The API root.'
    params do
    end
    get do
      present self, with: DV::Representers::Root
    end

    mount DV::Turns

    add_swagger_documentation api_version: 'v1'
  end
end