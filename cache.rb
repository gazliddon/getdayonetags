# ---------------------------------------------------------------------------------------------------------------------
# Crappy Generalised Cache
module Gaz

  class Cache

    def initialize &create_func
      @cache = {}
    end

    def get my_key, &block
      @cache[my_key] = yield my_key unless @cache[my_key]
      @cache[my_key]
    end

  end # class Cache

end

# ---------------------------------------------------------------------------------------------------------------------
# ends