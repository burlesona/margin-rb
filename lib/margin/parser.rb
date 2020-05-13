# frozen_string_literal: true

require 'strscan'
require 'margin/item'

module Margin

  # Notes:
  # - The parser requires a trailing newline at the end of the last item.
  # - Per the spec: leading and trailing dashes, colons, asterisks,
  #   chevrons, underscores and whitespaces, as well as blank lines, are ignored.
  module Parser

    IGNORED_CHARACTERS = /[\ \-\*:><_]/
    LINE_DECORATION = /#{IGNORED_CHARACTERS}*/
    EMPTY_LINE = /^#{IGNORED_CHARACTERS}*\n/
    TASK_START = /^\[.\]\ /
    ANNOTATION_ONLY = /^\[.*\]$/


    module LineMethods
      module_function
      # Get the inner value by scanning past all leading and trailing line decorations.
      def strip_line(string)
        s = StringScanner.new(string)
        raw_inner = ""
        s.skip LINE_DECORATION
        raw_inner += s.getch until s.match? (/#{LINE_DECORATION}$/)
        raw_inner
      end

      # Detect the offset of a raw line
      def detect_offset(string)
        s = StringScanner.new(string)
        s.match? (/\s*/)
      end

      # Detect if this matches the criteria for a task,
      # Return the status and rest of string if yes,
      # otherwise return false.
      def detect_task(string)
        return false unless string.match? TASK_START
        done = string[1] != " "
        rest = string.sub(TASK_START,"")
        [done, rest]
      end

      def detect_annotation_only(string)
        string.match? ANNOTATION_ONLY
      end

      def extract_annotations(string)
        value = ""
        current_annotation = ""
        annotations = []
        s = StringScanner.new(string)
        in_annotation = false
        until s.eos?
          c = s.getch
          case
          when c == "["
            in_annotation = true
          when c == "]"
            in_annotation = false
            annotations << structure_annotation(current_annotation)
            current_annotation = ""
          when in_annotation
            current_annotation += c
          else
            value += c
          end
        end
        value = value.strip
        value = nil if value.length == 0
        [value, annotations]
      end

      def structure_annotation(string)
        first, last = string.split(":",2)
        if last
          { key: first.strip, value: extract_annotation_value(last) }
        else
          { value: extract_annotation_value(first) }
        end
      end

      # Check if a value is really numeric, return the clean value
      def extract_annotation_value(string)
        string = string.strip
        case
        when i = Integer(string, exception: false) then i
        when f = Float(string, exception: false) then f
        else string
        end
      end
    end


    class Line
      include LineMethods

      attr_reader :raw_data,
                  :offset,
                  :type,
                  :done,
                  :value,
                  :annotations

      def initialize(raw_data)
        @raw_data = raw_data
        @offset = detect_offset(raw_data)
        @annotations = { notes: [], indexes: {} }
        parse!
      end

      private

      def parse!
        raw_inner = strip_line(raw_data)
        
        if detect_annotation_only(raw_inner)
          @type = :annotation
        elsif result = detect_task(raw_inner)
          @type = :task
          @done, raw_inner = result
        else
          @type = :item
        end

        @value, @annotations = extract_annotations(raw_inner)
      end
    end


    module_function

    def parse(text)
      s = StringScanner.new(text)
      lines = []
      until s.eos?
        raw = s.scan_until(/\n/)&.chomp
        break if raw.nil? # probably should handle this with a custom error
        lines << Line.new(raw) unless raw.match? (/^#{IGNORED_CHARACTERS}*$/)
      end
      parse_items Item.root, lines
    end

    def parse_items(parent, lines)
      return parent if !lines.any?
      while this_line = lines.shift do
        this_item = nil

        # handle this line
        case this_line.type
        when :item, :task
          this_item = Item.from_line(this_line)
          parent.children << this_item
        when :annotation
          parent.annotations += this_line.annotations
        else
          raise TypeError, "Unknown line type: `#{this_line.type}`"
        end
        
        break if this_item.nil?
        break if lines.empty?
        
        # now look ahead to decide what to do next
        next_line = lines.first
        parse_items(this_item, lines) if next_line.offset > this_line.offset
        break if next_line.offset < this_line.offset
      end
      parent
    end
  end
end
