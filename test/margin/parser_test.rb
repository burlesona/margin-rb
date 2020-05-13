# frozen_string_literal: true

require "test_helper"
require "margin/parser"

describe Parser do  
  describe Parser::LineMethods do
    let (:pl) { Parser::LineMethods }

    it "should detect offsets" do
      assert_equal 0, pl.detect_offset("hello")
      assert_equal 2, pl.detect_offset("  hello")
      assert_equal 2, pl.detect_offset("  * hello")
      assert_equal 4, pl.detect_offset("    * hello")
      assert_equal 3, pl.detect_offset("   hello")
    end

    it "should strip lines" do
      assert_equal "hello", pl.strip_line("** hello **")
      assert_equal "testing 1,2,3", pl.strip_line("- testing 1,2,3")
      assert_equal "a b c", pl.strip_line("a b c------")
      assert_equal "defg", pl.strip_line(">>>defg<<<")
    end

    it "should detect tasks" do
      refute pl.detect_task("I am not a task")
      refute pl.detect_task("[I am not a task]")
      refute pl.detect_task("Still not a task []")
      refute pl.detect_task("Still not a task [ ]")
      refute pl.detect_task("Still not a task [x]")

      done, rest = pl.detect_task("[ ] I actually AM a task.")
      refute done
      assert_equal "I actually AM a task.", rest

      done, rest = pl.detect_task("[x] Now I'm finished.")
      assert done
      assert_equal "Now I'm finished.", rest
    end

    it "should extract annotations" do
      value, annotations = pl.extract_annotations "I'm just a value."
      assert_equal "I'm just a value.", value
      assert_equal [], annotations
      
      value, annotations = pl.extract_annotations "[I'm just a big annotation.]"
      assert_nil value
      assert_equal [{value:"I'm just a big annotation."}], annotations

      value, annotations = pl.extract_annotations "[Something] I am a note"
      assert_equal "I am a note", value
      assert_equal [{value:"Something"}], annotations

      value, annotations = pl.extract_annotations "[prefix] this has a value [postfix]"
      assert_equal "this has a value", value
      assert_equal [{value:"prefix"},{value:"postfix"}], annotations

      value, annotations = pl.extract_annotations "[tag: cool] this is cool [label:neat]"
      assert_equal "this is cool", value
      assert_equal [{key: "tag", value: "cool"},{key:"label", value:"neat"}], annotations
    end

    it "should structure annotations" do
      assert_equal({value: "one"}, pl.structure_annotation("one"))
      assert_equal({value: "two"}, pl.structure_annotation("two"))
      assert_equal({key: "a", value: 1}, pl.structure_annotation("a: 1"))
      assert_equal({key: "b", value: 2}, pl.structure_annotation("b: 2"))
      assert_equal({key: "text", value: "foobar"}, pl.structure_annotation("text : foobar"))
    end
  end

  describe Parser::Line do
    it "should convert raw line data into a parsed value" do
      data = "** Hello, world! **"
      line = Parser::Line.new(data)
      assert_equal data, line.raw_data
      assert_equal "Hello, world!", line.value
      assert_equal 0, line.offset
    end
  end

  describe "simple lists" do
    let(:p){ Parser }

    it "should return an empty root" do
      r = p.parse("")
      assert r.is_a?(Item)
      assert r.root?
    end

    it "should return a list of items" do
      str = <<~MARGIN
        Shirt
        Pants
        Shoes
      MARGIN
      r = p.parse(str)
      assert_equal 3, r.children.count
      assert_equal "Shirt", r.children[0].value
      assert_equal "Pants", r.children[1].value
      assert_equal "Shoes", r.children[2].value
    end

    it "should return a list of items with annotations" do
      str = <<~MARGIN
        Shirt
          [price: 29.95]
        Pants
          [price: 54.99]
        Shoes
          [price: 74.00]
      MARGIN
      r = p.parse(str)
      assert_equal 3, r.children.count
      assert_equal "Shirt", r.children[0].value
      assert_equal ({key: "price", value: 29.95}), r.children[0].annotations.first
      assert_equal "Pants", r.children[1].value
      assert_equal ({key: "price", value: 54.99}), r.children[1].annotations.first
      assert_equal "Shoes", r.children[2].value
      assert_equal ({key: "price", value: 74.00}), r.children[2].annotations.first
    end

    it "should detect a list of tasks" do
      str = <<~MARGIN
        [*] Write a parser
        [*] Write tests
        [ ] Share with the world
      MARGIN

      r = p.parse(str)
      assert_equal 3, r.children.count
      assert_equal 3, r.children.count{|c|  c.task? }
      assert_equal 2, r.children.count{|c|  c.done? }
      assert_equal 1, r.children.count{|c| !c.done? }
    end
  end
end
