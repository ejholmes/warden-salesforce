module Warden
  module Salesforce
    class User
      attr_reader :token
      attr_reader :refresh_token
      attr_reader :instance_url
      attr_reader :raw_info

      def initialize(access_token)
        @token         = access_token.token
        @refresh_token = access_token.refresh_token
        @instance_url  = access_token.params['instance_url']
        @raw_info      = access_token.post(access_token['id']).parsed
      end

      def username
        raw_info['username']
      end

    end
  end
end
