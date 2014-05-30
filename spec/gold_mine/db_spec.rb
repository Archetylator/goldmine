require "spec_helper"

describe GoldMine::DB do
  add_temp_file
  subject { GoldMine::DB.new(path: temp_file.path) }

  describe "#initialize" do
    subject {  GoldMine::DB.new }
    let(:path) { subject.instance_variable_get("@path") }
    let(:options) { subject.instance_variable_get("@options") }

    context "without a :path option" do
      it "assigns built-in database path to the @path" do
        default_path = File.expand_path("../../../fortunes/fortunes", __FILE__)
        expect(path).to eq(default_path)
      end
    end

    context "without a :delim option" do
      it "assigns default delimiter to the :delim option" do
        expect(options[:delim]).to eq("%")
      end
    end
  end

  describe "#random" do
    temp_file <<-EOF.gsub(/^ {6}/, "")
      "His mind is like a steel trap ― full of mice."
              ― Foghorn Leghorn
      %
      "Humor is a drug which it's the fashion to abuse."
              ― William Gilbert
    EOF

    it "returns the instance of fortune class" do
      expect(subject.random).to be_a(GoldMine::Fortune)
    end

    it "returns the random fortune" do
      results = []
      1000.times { results << subject.random }
      expect(results.uniq.size).to be > 1
    end
  end

  describe "#fortunes" do
    temp_file <<-EOF.gsub(/^ {6}/, "")
      "Deliver yesterday, code today, think tomorrow."
      %
      "Die? I should say not, dear fellow. No Barrymore would allow such a
      conventional thing to happen to him."
              ― John Barrymore's dying words
      %
      "Do not stop to ask what is it;
       Let us go and make our visit."
              ― T. S. Eliot, "The Love Song of J. Alfred Prufrock"
    EOF

    it "returns the array with fortune instances" do
      array = subject.fortunes.map { |f| f.is_a?(GoldMine::Fortune) }
      expect(array).to_not include(false)
    end

    it "returns properly formated fortunes" do
      expect(subject.fortunes.first.content).to eq("\"Deliver yesterday, code today, think tomorrow.\"")
    end

    it "returns all fortunes from a database" do
      expect(subject.fortunes.size).to eq(3)
    end
  end
end