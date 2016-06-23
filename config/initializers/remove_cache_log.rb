Rails.cache.silence!
Rails.cache.mute { Rails.cache.read(:key) }