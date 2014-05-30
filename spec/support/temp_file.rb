require "tempfile"

module TempFile
  def self.included(example_group)
    example_group.extend(self)
  end

  def add_temp_file
    let(:temp_file) do
      Tempfile.new("goldmine")
    end
  end

  def temp_file(content = "")
    before do
      temp_file.open
      temp_file.write(content)
      temp_file.close
    end

    after do
      temp_file.unlink
    end
  end
end