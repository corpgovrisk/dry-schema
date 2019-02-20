module Dry
  module Schema
    # A set of messages used to generate errors
    #
    # @see Result#message_set
    #
    # @api public
    class MessageSet
      include Enumerable

      attr_reader :messages, :placeholders, :options

      # @api private
      def self.[](messages, options = EMPTY_HASH)
        new(messages.flatten, options)
      end

      # @api private
      def initialize(messages, options = EMPTY_HASH)
        @messages = messages
        @options = options
        initialize_placeholders!
      end

      # @api public
      def each(&block)
        return to_enum unless block
        messages.each(&block)
      end

      # @api public
      def to_h
        messages_map
      end
      alias_method :to_hash, :to_h
      alias_method :dump, :to_h

      # @api private
      def empty?
        messages.empty?
      end

      private

      # @api private
      def messages_map(messages = self.messages)
        messages.group_by(&:path).reduce(placeholders) do |hash, (path, msgs)|
          node = path.reduce(hash) { |a, e| a[e] }

          msgs.each do |msg|
            node << msg
          end

          node.map!(&:to_s)

          hash
        end
      end

      # @api private
      def paths
        @paths ||= messages.map(&:path).uniq
      end

      # @api private
      def initialize_placeholders!
        @placeholders = paths.reduce({}) do |hash, path|
          curr_idx = 0
          last_idx = path.size - 1
          node = hash

          while curr_idx <= last_idx do
            key = path[curr_idx]
            node = (node[key] || node[key] = curr_idx < last_idx ? {} : [])
            curr_idx += 1
          end

          hash
        end
      end
    end
  end
end
