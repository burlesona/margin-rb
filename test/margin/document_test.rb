# frozen_string_literal: true

require "test_helper"
require "margin/document"


describe Document do

  describe "interface" do
    it "should init empty" do
      assert Document.new
    end

    it "should always have a root" do
      d = Document.new
      assert d.root
      assert d.root.is_a?(Item)
      assert d.root.root?
    end

    it "should produce margin-formatted text" do
      assert_equal "", Document.new.to_margin
    end

    it "should produce json" do
      json = '{"raw_data":"root","type":"item","value":"root","annotations":[],"children":[]}'
      assert_equal json, Document.new.to_json
    end

    it "should accept margin-formatted text input" do
      d = Document.from_margin ""
      assert d
      assert d.is_a?(Document)
    end

    it "should accept json input" do
      d = Document.from_json "{}"
      assert d
      assert d.is_a?(Document)
    end
  end

  describe "parsing items" do
    # Note that the majority of parsing testing is done in the parser tests.
    it "should make a list of items" do
      str = <<~MARGIN
        Shirt
        Pants
        Shoes
      MARGIN
      d = Document.from_margin(str)
      assert_equal 3, d.root.children.count
      assert_equal "Shirt", d.root.children[0].value
      assert_equal "Pants", d.root.children[1].value
      assert_equal "Shoes", d.root.children[2].value
    end
  end

  describe "conversion" do
    def assert_json(correct_hash, json_string)
      assert JSON.generate(correct_hash) == json_string, "Generated JSON did not match."
    end

    it "should convert from Margin to JSON" do
      margin = <<~MARGIN
        Shirt
        Pants
        Shoes
      MARGIN
      correct = {
        raw_data: "root",
        type: "item",
        value: "root",
        annotations: [],
        children: [
          {
            raw_data: "Shirt",
            type: "item",
            value: "Shirt",
            annotations: [],
            children: []
          },
          {
            raw_data: "Pants",
            type: "item",
            value: "Pants",
            annotations: [],
            children: []
          },
          {
            raw_data: "Shoes",
            type: "item",
            value: "Shoes",
            annotations: [],
            children: []
          }
        ]
      }
      d = Document.from_margin(margin)
      assert_json correct, d.to_json
    end
  end
end