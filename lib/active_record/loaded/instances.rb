require 'active_record/loaded/instances/version'
require 'active_record/change_detector'

module ActiveRecord
  module Loaded
    module Instances

      def loaded_instances
        ActiveRecord::Loaded::Instances.loaded_instances(self)
      end

      def self.loaded_instances(ar, instances: [])
        return instances if instances.include? ar

        instances << ar
        ar._reflections.each do |association, _ref|
          association = association.to_sym
          next if !ar.association_cached?(association) || !ar.association(association).loaded?

          loaded_associations ar.association(association), instances: instances
        end
        instances
      end

      private

      def self.loaded_associations(association, instances:)
        if association.is_a? ActiveRecord::Associations::SingularAssociation
          loaded_instances(association.reader, instances: instances)
        elsif association.is_a? ActiveRecord::Associations::CollectionAssociation
          association.reader.each do |rel|
            loaded_instances(rel, instances: instances)
          end
        end
        instances
      end
    end
  end
end
