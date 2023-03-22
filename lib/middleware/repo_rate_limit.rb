# app/lib/middlewares/custom_rate_limit.rb
class RepoRateLimit
  def initialize(app)
    @app = app
  end

  def call(env)
    if should_allow?(env)
      @app.call(env)
    else
      request_quota_exceeded
    end
  end

  def should_allow?(env)
    key = "IP:#{env['action_dispatch.remote_ip']}"

    REDIS.set(key, 0, nx: true, ex: TIME_PERIOD)
    REDIS.incr(key) > LIMIT ? false : true
  end
end