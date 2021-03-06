module Xcake
  class TargetFileReferenceGenerator < Generator
    attr_accessor :root_node
    attr_accessor :installer_resolution

    def initialize(context)
      @context = context
      @root_node = Node.new

      repository = FileReferenceInstaller.repository
      puts "Registered Generators #{repository}"

      dependency_provider = DependencyProvider.new(repository)
      resolver = Molinillo::Resolver.new(dependency_provider, UI.new)
      @installer_resolution = resolver.resolve(repository)
    end

    def self.dependencies
      [TargetGenerator]
    end

    def process_files_for_target(target)
      native_target = @context.native_object_for(target)

      Dir.glob(target.include_files).each do |file|
        @root_node.create_children_with_path(file, native_target)
      end if target.include_files

      Dir.glob(target.exclude_files).each do |file|
        @root_node.remove_children_with_path(file, native_target)
      end if target.exclude_files
    end

    def visit_project(project)
      project.targets.each do |target|
        process_files_for_target(target)
      end

      root_node.accept(self)
    end

    def visit_node(node)
      return unless node.path
      puts "Adding #{node.path}..."

      #TODO: Don't use class as name
      #TODO: Filter and first generator
      #TODO: Debug logs for generator
      installer_class = @installer_resolution.tsort.detect do |i|
        i.name.can_install_node(node)
      end

      if installer_class != nil then
        installer = installer_class.name.new(context)
        node.accept(installer)
      end
    end
  end
end
