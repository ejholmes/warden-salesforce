Warden::Strategies.add(:salesforce) do
  # Need to make sure that we have a pure representation of the query string.
  # Rails adds an "action" parameter which causes the openid gem to error
  def params
    @params ||= Rack::Utils.parse_query(request.query_string)
  end

  def authenticate!
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
