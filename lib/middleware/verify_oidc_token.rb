# app/lib/middlewares/verify_oidc_token.rb
class VerifyOidcToken
  def initialize(app)
    @app = app
  end

  def call(env)
    if should_allow?(env)
      @app.call(env)
    else
      [401, {}, ['unauthenticated']]
    end
  end

  def should_allow?(env)
    load_context(env)
  rescue JWT::DecodeError
    false
  rescue StandardError
    false
  end

  def load_context(env)
    header = get_auth_header(env)
    return false if header.nil?

    token = header.split(' ').last
    env['context'] = JWT.decode(token, nil, true, { algorithms: ['RS256'], jwks: jwks_loader })
    env['repository'] = env['context']['repository']
  end

  def jwks_loader = lambda do |options|
    if options[:kid_not_found] && @cache_last_update < Time.now.to_i - 300
      logger.info("Invalidating JWK cache. #{options[:kid]} not found from previous cache")
      @cached_keys = nil
    end
    @cached_keys ||= begin
                       @cache_last_update = Time.now.to_i
                       # TODO: This ought to fetch the public signing keys
                       # based on the data in the token header. Instead of
                       # hardcoding to Github.com
                       jwks = JWT::JWK::Set.new(JSON.parse(github_jwks_hash.body))
                       jwks.select! { |key| key[:use] == 'sig' } # Signing Keys only
                       jwks
                     end
  end

  def get_auth_header(env)
    env['HTTP_AUTHORIZATION']
  end

  def github_jwks_hash
    Net::HTTP.get_response(
      URI('https://token.actions.githubusercontent.com/.well-known/jwks')
    )
  end
end