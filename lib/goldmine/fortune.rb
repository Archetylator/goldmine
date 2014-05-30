module Goldmine

  # Represents a single fortune.
  #
  # First argument is an entire text of fortune.
  # From that text a content and an attribution are extracted.
  #
  #   Fortune.new <<-EOF
  #     "Calvin Coolidge looks as if he had been weaned on a pickle."
  #             ― Alice Roosevelt Longworth
  #   EOF
  #
  #   Returns a fortune where content attribute is equal to "Calvin Coolidge
  #   looks as if he had been weaned on a pickle." and attribution attribute
  #   is equal to "Alice Roosevelt Longworth".
  #
  class Fortune
    ATTRB_RGXP = /^(\s*(―|--)|(―|--))\s*(?<attrb>.*)/

    def initialize(content = "")
      matches = content.match(ATTRB_RGXP)

      @content = content.chomp.sub(ATTRB_RGXP, "")
      @attribution = matches && matches[:attrb]
    end

    attr_accessor :content, :attribution

    def to_s
      if @content && !@content.empty? && @attribution
        <<-FORMAT.gsub(/^ {10}/, "")

          #{@content}
                  ― #{@attribution}

        FORMAT
      elsif @content && !@content.empty? && !@attribution
        <<-FORMAT.gsub(/^ {10}/, "")

          #{@content}

        FORMAT
      else
        ""
      end
    end
  end
end