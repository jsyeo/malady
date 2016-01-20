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

    class LetNode < Node
      attr_reader :bindings, :body, :identifiers, :values

      def initialize(filename, line, bindings, body)
        super
        @bindings = bindings
        @body = body
        @identifiers = @bindings.map(&:first)
        @values = @bindings.map(&:last)
      end

      def bytecode(g)
        pos(g)

        scope = Malady::Scope.new
        state = g.state
        state.scope.nest_scope scope

        blk = new_block_generator(g, @bindings)

        blk.push_state scope
        blk.state.push_super state.super
        blk.state.push_eval state.eval

        blk.state.push_name blk.name

        blk.required_args = @bindings.count
        blk.post_args = @bindings.count
        blk.total_args = @bindings.count
        blk.cast_for_multi_block_arg unless @bindings.count.zero?

        @identifiers.each do |id|
          blk.shift_array
          local = blk.state.scope.new_local(id.to_s)
          blk.set_local local.slot
          blk.pop
        end
        blk.pop unless @bindings.empty?

        blk.state.push_block

        body.bytecode(blk)

        blk.state.pop_block
        blk.ret

        blk.local_names = blk.state.scope.local_names
        blk.local_count = blk.state.scope.local_count
        blk.pop_state
        blk.close

        g.create_block blk

        @values.each do |val|
          val.bytecode(g)
        end

        g.send :call, @bindings.count
      end

      def new_block_generator(g, arguments)
        blk = g.class.new
        blk.name = g.state.name || :__block__
        blk.file = g.file
        blk.for_block = true

        blk.required_args = arguments.count
        blk.post_args = arguments.count
        blk.total_args = arguments.count
        blk.cast_for_multi_block_arg unless arguments.count.zero?

        blk
      end
    end
  end
end