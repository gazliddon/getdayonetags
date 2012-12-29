# ---------------------------------------------------------------------------------------------------------------------
# Crappy Generalised Cache
class Cache

  def initialize &create_func
    @cache = {}
    @create_func = create_func
  end

  def get my_key
    unles @cache[my_key]
      @cache[my_key] = @create_func.call my_key
    end

    @cache[my_key]
  end

end # class Cache


# ---------------------------------------------------------------------------------------------------------------------
# ends