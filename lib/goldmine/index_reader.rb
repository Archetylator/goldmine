module Goldmine

  # Reads an index for fortunes database. The index is a binary
  # file which contains a header and pointers.
  #
  # The header stores statistical information and instruction
  # specifying how to read the file. Pointer indicates an initial
  # position for the related fortune.
  #
  class IndexReader
    HEADER_SIZE  = 24
    POINTER_SIZE = 4

    def initialize(path)
      @path = path

      header = header_fields
      @version = header[0]
      @numstr = header[1]
      @longlen = header[2]
      @shortlen = header[3]
      @flags = header[4].to_switch
      @delim = header[5].chr
    end

    attr_reader :path, :numstr, :longlen, :shortlen, :version, :flags, :delim

    # Returns a hash with selected header fields.
    #
    def options
      {
        version: @version,
        delim: @delim,
        randomized: @flags[0],
        ordered: @flags[1],
        rotated: @flags[2],
        comments: @flags[3]
      }
    end

    # Returns a header.
    #
    # The header consists of six 32-bit unsigned integers.
    # Integers are stored in big-endian byte order.
    #
    # The order and meaning of the fields are as follows:
    #
    # [+version+] version number
    # [+numstr+] number of pointers
    # [+longlen+] size of longest fortune
    # [+shortlen+] size of shortest fortune
    # [+flags+] stores multiple booleans (bit-field)
    #       [1] randomize order
    #       [2] sorting in alphabetical order
    #       [4] Caesar encryption
    #       [8] allow comments
    # [+delim+] 8-bit unsigned integer packed to 32-bit
    #                which represents a delimeter character
    #
    def header_fields
      IO.binread(@path, HEADER_SIZE, 0).unpack("N5C1")
    end

    # Returns all pointers.
    #
    def get_pointers
      IO.binread(@path, @numstr * POINTER_SIZE, HEADER_SIZE).unpack("N*")
    end

    # Returns a pointer from a certain position.
    #
    def get_pointer_at(index)
      IO.binread(@path, POINTER_SIZE, HEADER_SIZE + POINTER_SIZE * index).unpack("N").first
    end

    def random_pointer
      get_pointer_at rand(@numstr)
    end
  end
end