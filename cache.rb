# ---------------------------------------------------------------------------------------------------------------------
# Crappy Generalised Cache
module Gaz

  class Cache

    def initialize &create_func
      @cache = {}
      @create_func = create_func
    end

    def get my_key
      @cache[my_key] = @create_func.call(my_key) unless @cache[my_key]
      @cache[my_key]
    end

  end # class Cache

end

# ---------------------------------------------------------------------------------------------------------------------
# ends