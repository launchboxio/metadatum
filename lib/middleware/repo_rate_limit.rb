# app/lib/middlewares/custom_rate_limit.rb
class RepoRateLimit
  TIME_PERIOD = 60 # no. of seconds
  LIMIT = 20 # no. of allowed requests / repository / minute

  def initialize(app)
    @app = app
  end

  def call(env)
    if should_allow?(env)
      @app.call(env)
    else
      [429, {}, ['Too Many Requests']]
    end
  end

  def should_allow?(env)
    key = env['repository']

    REDIS.set(key, "0", nx: true, ex: TIME_PERIOD)
    REDIS.incr(key) <= LIMIT
  end
end
