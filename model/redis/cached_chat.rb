require 'json'

class CachedChat < RedisBase
  prefix :cached_chat

  EXPIRE_SECONDS = 7.day.to_i
  MAX_LENGTH = 10

  def push(chat)
    RedisBase.pipelined do
      redis.lpush key, chat.to_json
      redis.ltrim key, 0, MAX_LENGTH - 1
      redis.expire key, EXPIRE_SECONDS
    end
  end

  def dump(chats)
    RedisBase.pipelined do
      chats.each do |chat|
        redis.lpush key, chat.to_json
      end
      redis.ltrim key, 0, MAX_LENGTH - 1
      redis.expire key, EXPIRE_SECONDS
    end
  end

  def load
    v = redis.lrange(key, 0, MAX_LENGTH - 1)
    return [] if v.blank?

    v.map do |vv|
      JSON.parse(vv)
    end
  end

  private

  def push_without_pipeline(chat)
  end
end
