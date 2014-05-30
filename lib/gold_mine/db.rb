module GoldMine

  # Database of fortunes.
  #
  # Example:
  #   db = DB.new(path: "/home/user/fortunes")
  #   db.random # => random fortune
  #
  # Options:
  # [:+path+]
  #   The path of database.
  #
  # [:+comments+]
  #   Pass true if allow comments is needed.
  #
  # [:+delim+]
  #   The character which is used as delimiter in a database.
  #
  class DB
    def self.default_options
      @default_options ||= {
        delim: "%"
      }
    end

    attr_reader :path, :options

    def initialize(options = {})
      @path = options.fetch(:path, GoldMine.default_db_path)
      @options = self.class.default_options.merge(options)
    end

    def random
      fortunes.sample
    end

    def fortunes
      @fortunes ||= read_fortunes
    end

    private

    def find_fortune(index)
      read_fortunes(offset: index, size: 1).first
    end

    def read_fortunes(options = {})
      offset = options.fetch(:offset, 0)
      max_size = options.fetch(:size, Float::INFINITY)
      fortunes, text = [], ""

      File.open(@path, "r") do |file|
        file.seek(offset)
        file.each_line do |line|
          break if fortunes.size == max_size

          if @options[:comments]
            next if line[/^#{@options[:delim]*2}/]
          end

          if line[/^#{@options[:delim]}/] || file.eof?
            text << line if file.eof?
            fortunes << Fortune.new(text) unless text.chomp.empty?
            text.clear
            next
          end

          text << line
        end
      end

      fortunes
    end
  end
end