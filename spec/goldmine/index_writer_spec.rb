require "spec_helper"
require "tmpdir"

describe Goldmine::IndexWriter do
  add_temp_file
  subject { described_class.new(temp_file.path) }

  describe "#initialize" do
    let(:options) { subject.instance_variable_get("@options") }

    context "without an options" do
      it "assigns default options to @options" do
        default_options = {
          version: 2,
          delim: "%",
          randomized: false,
          ordered: false,
          rotated: false,
          comments: false
        }
        expect(options).to eq(default_options)
      end
    end

    context "with an options" do
      subject { described_class.new(temp_file.path, version: 12) }

      it "merged them with the default options" do
        expect(options[:version]).to eq(12)
      end
    end

    it "assings to @shortlen very high number" do
      shortlen = subject.instance_variable_get("@shortlen")
      expect(shortlen).to be >= 99999
    end

    context "with an :ordered option and a :randomized option" do
      subject { described_class.new(temp_file.path, randomized: true, ordered: true) }

      it "excludes :randomized" do
        flags = subject.instance_variable_get("@flags")
        expect(flags[:randomized]).to be_false
      end
    end
  end

  describe "#load_pointers" do
    temp_file <<-EOF.gsub(/^ {6}/, "")
      %
      I Like Facebook
      %
      "I see fire"
              -- Ed Sheeran
      %
      CTSG
    EOF

    let(:load_pointers) { subject.load_pointers }

    context "when :comments option is true" do
      subject { described_class.new(temp_file.path, comments: true) }

      temp_file <<-EOF.gsub(/^ {8}/, "")
        %% It's new!
        "Be or not to be"
        %% What?!
                -- Shakespeare
        %
        %% Todo: Change it!
      EOF

      describe "omits lines starting with double delimeter" do
        it { expect(load_pointers.size).to eq(1) }
        it { expect(load_pointers[0][0]).to eq(13) }
      end
    end

    it "returns the array with correct size" do
      expect(load_pointers.size).to eq(3)
    end

    it "assings end of file position to @eof" do
      expect(subject.instance_variable_get("@eof")).to eq(62)
    end

    it "assings length of shortest fortune to @shortlen" do
      expect(subject.instance_variable_get("@shortlen")).to eq(5)
    end

    it "assings length of longest fortune to @longlen" do
      expect(subject.instance_variable_get("@longlen")).to eq(35)
    end

    describe "loads a fortune as an array" do
      it { expect(load_pointers.sample).to be_a(Array) }

      it "where first element is a correct pointer" do
        expect(load_pointers[1][0]).to eq(20)
      end

      it "where second element is a first character" do
        expect(load_pointers[0][1]).to eq("I")
      end

      it "even when is first and preceded by a delimeter" do
        expect(load_pointers[0][0]).to eq(2)
      end

      it "even when is located at the bottom of the file" do
        expect(load_pointers[2][0]).to eq(57)
      end
    end
  end

  describe "#order_pointers!" do
    it "organizes @pointers alphabetically" do
      subject.instance_variable_set("@pointers", [[23, "S"], [43, "A"], [61, "Z"]])
      subject.order_pointers!
      expect(subject.instance_variable_get("@pointers")).to eq([[43, "A"], [23, "S"], [61, "Z"]])
    end
  end

  describe "#shuffle_pointers!" do
    it "shuffles @pointers" do
      input = [[0, "A"], [1, "B"], [2, "C"]]
      subject.instance_variable_set("@pointers", input)
      subject.shuffle_pointers!
      expect(subject.instance_variable_get("@pointers")).to_not eq(input)
    end
  end

  describe "#write" do
    context "when @index_path is presence" do
      before do
        subject.instance_variable_set("@index_path", Dir.tmpdir + "/custom.dat")
      end

      it "saves a file at @index_path" do
        subject.write
        expect(File.exists?(subject.instance_variable_get("@index_path"))).to be_true
      end
    end

    context "when @index_path is not presence" do
      it "savas a file at @path.dat" do
        subject.write
        expect(File.exists?(subject.instance_variable_get('@path') + ".dat")).to be_true
      end
    end
  end

  describe "#offsets" do
    it "returns offsets from @pointers" do
      subject.instance_variable_set("@pointers", [[0, "A"], [1, "B"]])
      expect(subject.offsets).to eq([0, 1])
    end
  end

  describe "#packed_pointers" do
    describe "packs offsets into binary sequence" do
      it "32-bit unsigned and big-endian" do
        subject.instance_variable_set("@pointers", [[0, "A"], [22, "B"], [30, "C"]])
        expect(subject.packed_pointers).to eq("\x00\x00\x00\x00\x00\x00\x00\x16\x00\x00\x00\x1E")
      end
    end
  end

  describe "#packed_eof" do
    describe "packs @eof into binary sequence" do
      it "as 32-bit unsigned big-endian" do
        subject.instance_variable_set("@eof", 100)
        expect(subject.packed_eof).to eq("\x00\x00\x00d")
      end
    end
  end

  describe "#packed_header" do
    before do
      subject.instance_variable_set("@version", 2)
      subject.instance_variable_set("@numstr", 23)
      subject.instance_variable_set("@longlen", 31)
      subject.instance_variable_set("@shortlen", 7)
      subject.instance_variable_set("@flags", 0)
      subject.instance_variable_set("@delim", "%")
    end

    describe "packs header into binary sequence with big-endian convention where" do
      let(:unpacked_header) { subject.packed_header.unpack("N*") }

      ["version", "numstr", "longlen", "shortlen", "flags"].each_with_index do |e, i|
        it "#{i+1} element is a 32-bit unsigned integer representing #{e}" do
          expect(unpacked_header[i]).to eq(subject.instance_variable_get("@#{e}"))
        end
      end

      it "6 element is a 32-bit integer representing delim" do
        expect(unpacked_header[5]).to eq(subject.instance_variable_get("@delim").ord << 24)
      end
    end
  end
end
