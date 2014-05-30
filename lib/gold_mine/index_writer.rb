module GoldMine

  # Creates a file which consists of a table describing
  # the file, a table of pointers and an end of file position
  # of related database. This file is called an index.
  #
  # The index allows fast access to fortunes.
  # Provides additional info about a database e.g
  # gives information if fortunes are ordered or encrypted.
  #
  # First argument is a path of fortune database.
  # The second is an optional hash of options.
  #
  # Options:
  # [:+index_path+]
  #   The path under which the file will be saved.
  #
  # [:+version+]
  #   The version of writer.
  #
  # [:+delim+]
  #   The character which is used as delimiter in a database.
  #
  # [:+randomized+]
  #   Passing true will shuffle pointers.
  #
  # [:+ordered+]
  #   When enabled sorts pointers in an alphabetical order.
  #
  # [:+rotated+]
  #   Pass true if pointers should be encrypted (Caesar cipher).
  #
  # [:+comments+]
  #   If true allows comments in database.
  #
  class IndexWriter
    def self.default_options
      @default_options ||= {
        version: 2,
        delim: "%",
        randomized: false,
        ordered: false,
        rotated: false,
        comments: false
      }
    end

    def initialize(path, options = {})
      @path = path

      options = self.class.default_options.merge(options)

      @options = options
      @longlen = 0
      @numstr = 0
      @eof = 0

      # It's very important to keep it high.
      # Otherwise in some cases shortest
      # string will not be assigned.
      #
      @shortlen = 99999

      @index_path = options[:index_path]
      @version = options[:version]
      @delim = options[:delim]

      # An arrangement excludes a randomness.
      #
      options[:randomized] = false if options[:ordered]

      @flags = BitSwitch.new({
        randomized: options[:randomized],
        ordered: options[:ordered],
        rotated: options[:rotated],
        comments: options[:comments]
      })

      @pointers = load_pointers
      @numstr = @pointers.size

      order_pointers! if @flags[:ordered]
      shuffle_pointers! if @flags[:randomized]
    end

    attr_reader :version, :delim, :flags, :pointers, :longlen, :shortlen,
                        :numstr

    # When a path for index is not defined
    # returns identical path to the database, but
    # adds .dat extension at the end.
    #
    def index_path
      @index_path || "#{@path}.dat"
    end

    def load_pointers
      dregex = /^#{@delim}/
      cregex = /^#{@delim*2}/
      fregex = /[a-zA-Z0-9]/
      pointers = []
      length = 0
      offset = 0
      fchar = ""
      new_string = true

      File.open(@path) do |file|
        file.each_with_index do |line, index|
          if @flags[:comments]
            next if line[cregex]
          end

          if new_string && !line[dregex]
            fchar = line[fregex][0] if line[fregex]
            offset = (file.pos - line.size)
            new_string = false
          end

          if line[dregex] || file.eof?
            if file.eof?
              @eof = file.pos
              length += line.size
            end

            unless length.zero?
              pointers << [offset, fchar]

              @longlen = length if length > @longlen
              @shortlen = length if length < @shortlen

              length = 0
              new_string = true
            end

            next
          end

          length += line.size
        end
      end

      pointers
    end

    def order_pointers!
      @pointers.sort! { |x,y| [x[1], x[0]] <=> [y[1], y[0]] }
    end

    def shuffle_pointers!
      @pointers = Hash[@pointers.to_a.shuffle]
    end

    def write
      File.write(index_path, packed_header << packed_pointers << packed_eof)
    end

    # Returns an array of pointers.
    #
    # @pointers is an array where each element
    # is an array. The array contains an offset at first
    # and a first character of fortune as second.
    # Described method extracts offsets.
    #
    def offsets
      @pointers.map { |p| p.first }
    end

    # Packs the pointers as 32-bit unsigned
    # integers in big-endian byte order.
    #
    def packed_pointers
      offsets.pack("N*")
    end

    # Packs a database end of file position as 32-bit
    # unsigned integer in big-endian byte order.
    #
    def packed_eof
      [@eof].pack("N")
    end

    # Packs the header fields as 32-bit unsigned
    # unsigned integers in big-endian byte order.
    #
    def packed_header
      [
        @version,
        @numstr,
        @longlen,
        @shortlen,
        @flags.to_i,
        @delim.ord << 24 # bitpacked to 32-bit integer
      ].pack("N6")
    end
  end
end