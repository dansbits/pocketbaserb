require 'net/http'
require 'json'

module Pocketbase
  class Client

    def initialize(host)
      @host = host
    end

    def authenticate_with_password(username, password)
      uri = URI(@host + "/api/collections/users/auth-with-password")
      
      data = { identity: username, password: password }

      headers = {'content-type': 'application/json'}
      response = Net::HTTP.post(uri, JSON.generate(data), headers)

      if response.code == 200
        @access_token = JSON.parse(response.body)["token"]
      end
    end

    def get_list(collection, options)
      uri = URI(@host + "/api/collections/#{collection}/records")

      query = {}
      
      if options[:filter]
        query[:filter] = "(#{options[:filter]})"
      end

      uri.query = URI.encode_www_form query

      headers = {'content-type': 'application/json'}

      if @access_token
        headers['Authorization'] = @access_token
      end

      response = Net::HTTP.get_response(uri, headers)

      if response.code == "200"
        body = JSON.parse(response.body)
        return body['items']
      end
    end
  end
end