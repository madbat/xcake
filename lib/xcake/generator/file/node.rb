require 'xcodeproj'

module Xcake
  module Generator
    class File
      class Node

        attr_accessor :component
        attr_accessor :path
        attr_accessor :parent
        attr_accessor :children
        attr_accessor :targets

        def initialize
          self.children = []
          self.targets = []
        end

        def create_children_with_path(path, target)

          components = path.split('/').keep_if do |c|
            c != "."
          end

          component = components.shift
          child = children.find do |c|
            c.component == component
          end

          if child == nil

            child = Node.new

            child.component = component
            child.path = path
            child.parent = self
            child.targets << target

            children << child
          end

          child
        end

        def remove_children_with_path(components, target)

        end

        def traverse(&block)
          children.each do |c|
            block.call(c) if block_given?
            c.traverse(&block)
          end
        end
      end
    end
  end
end
