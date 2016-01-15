module Malady
  module AST
    class Node
      attr_reader :filename, :line

      def initialize(filename="(script)", line=1, *args)
        @filename = filename
        @line = line
      end

      def pos(g)
        g.set_line line
      end
    end

    class Program < Node
      attr_reader :body

      def initialize(filename, line, body)
        super
        @body = body
      end

      def bytecode(g)
        g.file = (filename || :"(malady)").to_sym
        pos(g)

        body.each_with_index do |expression, idx|
          expression.bytecode(g)
          g.pop unless idx == body.size - 1
        end

        g.finalize
      end
    end

    class SymbolNode < Node
      attr_reader :name

      def initialize(filename, line, name)
        super
        @name = name
      end

      def bytecode(g)
        pos(g)
        local = g.state.scope.search_local(name)
        local.get_bytecode(g)
      end
    end

    class IntegerNode < Node
      attr_reader :value

      def initialize(filename, line, value)
        super
        @value = value.to_i
      end

      def bytecode(g)
        pos(g)
        g.push_int value
      end
    end

    class BinaryNode < Node
      attr_reader :lhs, :rhs

      def initialize(filename, line, lhs, rhs)
        super
        @lhs = lhs
        @rhs = rhs
      end
    end

    class AddNode < BinaryNode
      def bytecode(g)
        pos(g)
        lhs.bytecode(g)
        rhs.bytecode(g)
        g.send(:+, 1)
      end
    end

    class MinusNode < BinaryNode
      def bytecode(g)
        pos(g)
        lhs.bytecode(g)
        rhs.bytecode(g)
        g.send(:-, 1)
      end
    end

    class DivideNode < BinaryNode
      def bytecode(g)
        pos(g)
        lhs.bytecode(g)
        rhs.bytecode(g)
        g.send(:/, 1)
      end
    end

    class MultiplyNode < BinaryNode
      def bytecode(g)
        pos(g)
        lhs.bytecode(g)
        rhs.bytecode(g)
        g.send(:*, 1)
      end
    end

    class AssignNode < Node
      attr_reader :name, :value

      def initialize(filename, line, name, value)
        super
        @name = name
        @value = value
      end

      def bytecode(g)
        pos(g)
        value.bytecode(g)
        local = g.state.scope.new_local(name)
        local.reference.set_bytecode(g)
      end
    end
  end
end
