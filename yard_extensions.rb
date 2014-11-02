require 'yard'

class BinaryStructureHandler < YARD::Handlers::Ruby::Base
  handles method_call(:binary_structure)
  namespace_only

  def process
    parse_block(statement.last.last, owner: namespace)
  end
end
