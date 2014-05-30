module Goldmine

  # Database with a related index file.
  #
  class IDB < DB
    attr_reader :index_reader

    def initialize(options = {})
      super

      @index_reader = IndexReader.new("#{@path}.dat")
      @options = @index_reader.options
    end

    def random
      find_fortune(@index_reader.random_pointer)
    end
  end
end