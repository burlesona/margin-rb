# frozen_string_literal: true

require 'json'

module Margin
  class Item
    attr_accessor :raw_data,
                  :type,
                  :value,
                  :done,
                  :annotations,
                  :children

    def initialize(raw_data: "", type: :item, done: false, value: "", annotations: [], children: [])
      @raw_data = raw_data
      @type = type
      @done = done
      @value = value
      @annotations = annotations
      @children = children
    end

    def task?
      type == :task
    end

    def done?
      done
    end

    def root?
      value == "root"
    end

    def as_json
      h = {}
      h[:raw_data] = raw_data
      h[:type] = type
      h[:value] = value
      h[:done] = done if type == :task
      h[:annotations] = annotations
      h[:children] = children.map(&:as_json)
      h
    end

    def to_json(pretty: false)
      pretty ? JSON.pretty_generate(as_json) : JSON.generate(as_json)
    end

    class << self
      def root
        new raw_data: "root", value: "root"
      end

      def from_line(line)
        new raw_data: line.raw_data,
            type: line.type,
            value: line.value,
            done: line.done,
            annotations: line.annotations
      end
    end
  end
end