require "spec_helper"

describe Goldmine::IndexReader do
  add_temp_file
  subject { described_class.new(temp_file.path) }

  INDEX_HEADER = {
    version: 2,
    numstr: 3,
    longlen: 612,
    shortlen: 28,
    flags: 0,
    delim: 37
  }

  temp_file (INDEX_HEADER.values + [0, 12, 154]).pack("N*")

  describe "#initialize" do
    it "assigns a path to the @path" do
      expect(subject.instance_variable_get("@path")).to eq(temp_file.path)
    end
  end

  describe "#header_fields" do
    it "returns an array of each value extracted" do
      expect(subject.header_fields).to be_instance_of(Array)
    end

    it "returns an array including six elements" do
      expect(subject.header_fields.size).to eq(6)
    end

    INDEX_HEADER.each_with_index do |(element, value), index|
      it "returns an array where element at #{index+1} position is a #{element}" do
        expect(subject.header_fields[index]).to eq(value)
      end
    end
  end

  describe "#get_pointers" do
    it "returns an array instance" do
      expect(subject.get_pointers).to be_instance_of(Array)
    end

    it "extracts pointers from index file" do
      expect(subject.get_pointers).to eq([0, 12, 154])
    end
  end

  describe "#get_pointer_at" do
    it "returns pointer by index" do
      expect(subject.get_pointer_at(1)).to eq(12)
    end
  end

  describe "#random_pointer" do
    it "returns random pointer" do
      results = []
      1000.times { results << subject.random_pointer }
      expect(results.uniq.size).to be > 1
    end
  end
end