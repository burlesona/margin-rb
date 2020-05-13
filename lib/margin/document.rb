# frozen_string_literal: true

require 'json'
require 'margin/parser'

module Margin
  class Document
    attr_reader :root

    def initialize(input="", format: :margin)
      @root = Item.root
      case format
      when :margin then parse_margin!(input)
      when :json then parse_json!(input)
      else raise ArgumentError, "Allowed formats: :margin, :json"
      end
    end

    def to_margin
      ""
    end

    def to_json(pretty: false)
      root.to_json(pretty: pretty)
    end

    private

    def parse_margin!(input)
      @root = Parser.parse(input)
    end

    def parse_json!(input)
    end

    class << self
      def from_margin(input)
        new(input, format: :margin)
      end

      def from_json(input)
        new(input, format: :json)
      end
    end
  end
end