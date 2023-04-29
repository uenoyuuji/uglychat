require 'singleton'
require 'redis'
require 'hiredis'

# @example
# class CachedPost < RedisBase
#   prefix :cached_post
#
#   MAX_POSTS = 10
#   EXPIRE_SECONDS = 30.day.to_i
#
#   def initialize(user_id, type_id)
#     super(user_id, type_id)
#   end
#
#   def push(post)
#     redis.lpush key, post.to_s
#     redis.ltrim key, 0, MAX_POSTS - 1
#     redis.expire key, EXPIRE_SECONDS
#   end
#
#   def load
#     redis.lrange key, 0, MAX_POSTS - 1 || []
#   end
# end
class RedisBase
  attr_reader :key

  def self.prefix(name)
    name = name.to_s
    raise 'invalid character ":" in a prefix name' if name.include?(':')
    const_set 'PREFIX'.to_sym, name
  end

  def self.pipelined(&block)
    CachedRedisConnection.instance.connection.pipelined(&block)
  end

  def initialize(*args)
    # argsに:が含まれるのかはチェックしない。prefixは定義時にエラーだがこちらは実行時であるため。
    prefix = self.class.const_defined?(:PREFIX) ? self.class.const_get(:PREFIX) : self.class.name.underscore
    joined_args = args.map(&:to_s).join(':')
    @key = "#{prefix}:#{joined_args}"
  end

  def redis
    CachedRedisConnection.instance.connection
  end

  def delete
    redis.del key
  end

  class CachedRedisConnection
    attr_accessor :environment

    include Singleton

    EXPIRE_SECONDS = 60 * 60

    def connection
      now = Time.now.to_i

      if RequestStore.store[:redis_connection_started_at] && RequestStore.store[:redis_connection_started_at] + EXPIRE_SECONDS < now
        RequestStore.store[:redis_connection]&.quit
        RequestStore.store[:redis_connection] = nil
      end

      v = RequestStore.store[:redis_connection]
      if v.nil?
        v = Redis.new(
          driver: :hiredis,
          host: host,
          port: port,
          db: db,
          timeout: timeout,
          reconnect_attempts: reconnect_attempts
        )
        RequestStore.store[:redis_connection] = v
        RequestStore.store[:redis_connection_started_at] = now
      end
      v
    end

    def quit
      RequestStore.store[:redis_connection]&.quit
    end

    private

    def host
      environment['host']
    end

    def port
      environment['port']
    end

    def db
      environment['db']
    end

    def timeout
      environment['timeout']
    end

    def reconnect_attempts
      environment['reconnect_attempts']
    end
  end
end
