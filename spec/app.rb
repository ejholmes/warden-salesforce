require 'sinatra'

module Example
  class App < Sinatra::Base
    enable  :sessions
    enable  :raise_errors
    disable :show_exceptions

    use Warden::Manager do |manager|
      manager.default_strategies :salesforce
      manager.failure_app = BadAuthentication

      manager[:salesforce_client_id]    = ENV['SALESFORCE_CLIENT_ID']     || 'ee9aa24b64d82c21535a'
      manager[:salesforce_secret]       = ENV['SALESFORCE_CLIENT_SECRET'] || 'ed8ff0c54067aefb808dab1ca265865405d08d6f'

      manager[:salesforce_scopes]       = 'api'
      manager[:salesforce_oauth_domain] = ENV['SALESFORCE_OAUTH_DOMAIN'] || 'https://login.salesforce.com'
      manager[:salesforce_callback_url] = '/auth/salesforce/callback'
    end

    helpers do
      def ensure_authenticated
        unless env['warden'].authenticate!
          throw(:warden)
        end
      end

      def user
        env['warden'].user
      end
    end

    get '/' do
      ensure_authenticated
      <<-EOS
      <h2>Token, #{user.username}!</h2>
      <h3>Instance URL, #{user.instance_url}</h3>
      #{user.raw_info}
      EOS
    end

    get '/redirect_to' do
      ensure_authenticated
      "Hello There, #{user.name}! return_to is working!"
    end

    get '/auth/salesforce/callback' do
      ensure_authenticated
      redirect '/'
    end

    get '/logout' do
      env['warden'].logout
      "Peace!"
    end
  end

  class BadAuthentication < Sinatra::Base
    get '/unauthenticated' do
      status 403
      "Unable to authenticate, sorry bud."
    end
  end

  def self.app
    @app ||= Rack::Builder.new do
      run App
    end
  end
end
