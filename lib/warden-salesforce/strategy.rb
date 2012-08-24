Warden::Strategies.add(:salesforce) do
  # Need to make sure that we have a pure representation of the query string.
  # Rails adds an "action" parameter which causes the openid gem to error
  def params
    @params ||= Rack::Utils.parse_query(request.query_string)
  end

  def authenticate!
    if(params['code'] && params['state'] &&
       env['rack.session']['salesforce_oauth_state'] &&
       env['rack.session']['salesforce_oauth_state'].size > 0 &&
       params['state'] == env['rack.session']['salesforce_oauth_state'])
      begin
        #api = api_for(params['code'])

        #success!(Warden::Github::Oauth::User.new(Yajl.load(user_info_for(api.token)), api.token))
      rescue OAuth2::Error
        %(<p>Outdated ?code=#{params['code']}:</p><p>#{$!}</p><p><a href="/auth/salesforce">Retry</a></p>)
      end
    else
      env['rack.session']['salesforce_oauth_state'] = state
      env['rack.session']['return_to'] = env['REQUEST_URI']
      throw(:warden, [ 302, {'Location' => authorize_url}, [ ]])
    end
  end

private

  def client
    @client ||= OAuth2::Client.new client_id, secret, {
      :site          => oauth_domain,
      :token_url     => '/services/oauth2/token',
      :authorize_url => '/services/oauth2/authorize'
    }
  end

  def authorize_url
    client.auth_code.authorize_url(
      :state        => state,
      :scope        => scopes,
      :redirect_uri => callback_url
    )
  end

  def state
    @state ||= Digest::SHA1.hexdigest(rand(36**8).to_s(36))
  end

  def oauth_domain
    config[:salesforce_oauth_domain]
  end

  def client_id
    config[:salesforce_client_id]
  end

  def secret
    config[:salesforce_secret]
  end

  def scopes
    config[:salesforce_scopes]
  end

  def config
    env['warden'].config
  end

  def callback_url
    absolute_url(request, env['warden'].config[:salesforce_callback_url], env['HTTP_X_FORWARDED_PROTO'])
  end

  def absolute_url(request, suffix = nil, proto = "http")
    port_part = case request.scheme
                when "http"
                  request.port == 80 ? "" : ":#{request.port}"
                when "https"
                  request.port == 443 ? "" : ":#{request.port}"
                end

    proto = "http" if proto.nil?
    "#{proto}://#{request.host}#{port_part}#{suffix}"
  end
end
