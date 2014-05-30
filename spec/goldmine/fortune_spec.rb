require "spec_helper"

describe Goldmine::Fortune do
  describe "#initialize" do
    context "with content" do
      subject do
        Goldmine::Fortune.new <<-EOF.gsub(/^ {10}/, "")
          I hate quotations.
                  ― Ralph Waldo Emerson
        EOF
      end

      it "assigns a text without attribution to the @content" do
        expect(subject.instance_variable_get("@content")).to eq("I hate quotations.\n")
      end

      it "assigns an attribution to the @attribution" do
        expect(subject.instance_variable_get("@attribution")).to eq("Ralph Waldo Emerson")
      end
    end
  end

  describe "#to_s" do
    shared_examples "a formatting" do |format|
      it "returns the string in the correct format" do
        expect(subject.to_s).to eq(format)
      end
    end

    context "when a content is empty and an attribution is empty" do
      it "returns the empty string" do
        expect(subject.to_s).to eq("")
      end
    end

    context "when a content is empty and an attribution is not empty" do
      before { subject.instance_variable_set("@attribution", "Yogi Berra") }

      it "returns the empty string" do
        expect(subject.to_s).to eq("")
      end
    end

    context "when a content is not empty and an attribution is empty" do
      before { subject.instance_variable_set("@content", "You can observe a lot just by watching.") }

      include_examples "a formatting", <<-EOS.gsub(/^ {8}/, "")

        You can observe a lot just by watching.

      EOS
    end

    context "when an content is not empty and an attribution is not empty" do
      before do
        subject.instance_variable_set("@attribution", "Yogi Berra")
        subject.instance_variable_set("@content", "You can observe a lot just by watching.")
      end

      include_examples "a formatting", <<-EOS.gsub(/^ {8}/, "")

        You can observe a lot just by watching.
                ― Yogi Berra

      EOS
    end
  end
end