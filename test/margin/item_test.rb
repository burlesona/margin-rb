# frozen_string_literal: true

require "test_helper"
require "margin/item"

describe Item do
  describe "interface" do
    let(:item) { Item.new }

    it "inits" do
      assert item
    end

    it "has raw_data" do
      assert_equal "", item.raw_data
    end

    it "has value" do
      assert_equal "", item.value
    end

    it "has annotations" do
      assert_equal [], item.annotations
    end

    it "has children" do
      assert_equal [], item.children
    end

    it "should make an empty root" do
      r = Item.root
      assert_equal "root", r.raw_data
      assert_equal "root", r.value
      assert_equal [], r.annotations
      assert_equal [], r.children
      assert r.root?
    end
  end
end
