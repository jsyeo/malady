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
        local = g.state.scope.new_local(name)
        value.bytecode(g)
        local.reference.set_bytecode(g)
      end
    end

    class TrueBooleanNode < Node
      def bytecode(g)
        pos(g)
        g.push_true
      end
    end

    class FalseBooleanNode < Node
      def bytecode(g)
        pos(g)
        g.push_false
      end
    end

    class IfNode < Node
      attr_reader :condition, :then_branch, :else_branch
      def initialize(filename, line, condition, then_branch, else_branch)
        super
        @condition = condition
        @then_branch = then_branch
        @else_branch = else_branch
      end

      def bytecode(g)
        pos(g)

        end_label = g.new_label
        else_label = g.new_label

        condition.bytecode(g)
        g.goto_if_false else_label
        then_branch.bytecode(g)
        g.goto end_label

        else_label.set!
        else_branch.bytecode(g)

        end_label.set!
      end
    end

    class LessThanNode < BinaryNode
      def bytecode(g)
        pos(g)
        lhs.bytecode(g)
        rhs.bytecode(g)
        g.send(:<, 1)
      end
    end

    class FnNode < Node
      attr_reader :arguments, :body

      def initialize(filename, line, arguments, body)
        @filename = filename
        @line = line
        @arguments = arguments
        @body = body
      end

      def bytecode(g)
        pos(g)

        # get a new scope
        scope = Malady::Scope.new

        # nest the scope in the current context
        state = g.state
        state.scope.nest_scope scope

        # get a new generator for our block
        blk = new_block_generator(g, @arguments)

        # push our scope
        blk.push_state scope

        # setup the state in our block
        blk.state.push_super state.super
        blk.state.push_eval state.eval
        blk.state.push_name blk.name

        # our args are locals in the block
        @arguments.each do |id|
          blk.shift_array
          local = blk.state.scope.new_local(id.to_s)
          blk.set_local local.slot
          blk.pop
        end
        blk.pop if !@arguments.empty?

        # push the block
        blk.state.push_block

        # compile the body of the closure in the block
        body.bytecode(blk)

        # pop the block
        blk.state.pop_block
        blk.ret

        # pop the state
        blk.local_names = blk.state.scope.local_names
        blk.local_count = blk.state.scope.local_count
        blk.pop_state
        blk.close

        # create the block in our current generator
        g.create_block blk
      end

      def new_block_generator(g, arguments)
        blk = g.class.new
        blk.name = g.state.name || :__block__
        blk.file = g.file
        blk.for_block = true

        blk.required_args = arguments.count
        blk.post_args = arguments.count
        blk.total_args = arguments.count
        blk.cast_for_multi_block_arg if !arguments.count.zero?

        blk
      end
    end

    class LetNode < FnNode
      attr_reader :bindings, :identifiers, :values

      def initialize(filename, line, bindings, body)
        @bindings = bindings
        @identifiers = @bindings.map(&:first)
        @values = @bindings.map(&:last)
        super(filename, line, identifiers, body)
      end

      # A LetNode is basically a closure with its arguments applied to the bindings
      def bytecode(g)
        super(g)

        # compile bindings' values
        @values.each do |val|
          val.bytecode(g)
        end

        # send :call to the block
        g.send :call, @bindings.count
      end
    end

    class FunctionCallNode < Node
      attr_reader :function, :arguments

      def initialize(filename, line, function, arguments)
        super
        @function = function
        @arguments = arguments
      end

      def bytecode(g)
        function.bytecode(g)

        @arguments.each do |val|
          val.bytecode(g)
        end

        g.send :call, @arguments.count
      end
    end
  end
end
