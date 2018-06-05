require 'active_record/loaded/instances/version'

module ActiveRecord
  module ChangeDetector
    extend ActiveSupport::Concern

    include ActiveRecord::Callbacks

    included do
      before_save :stack_update_event
      before_destroy :stack_destroy_event
      after_create :stack_create_event
      after_commit :pop_and_process_changes
      after_rollback :reset_change_stack
    end

    def reload(options = nil)
      reset_change_stack
      super
    end

    private

    def stack_create_event
      change_stack << [self.class, 'create', primary_key_value]
    end

    def stack_destroy_event
      change_stack << [self.class, 'destroy', primary_key_value]
    end

    def stack_update_event
      change_stack << [self.class, 'update', primary_key_value] if persisted?
      self._reflections.select do |association_name, reflection|
        next unless reflection.is_a?(ActiveRecord::Reflection::BelongsToReflection) && !reflection.through_reflection?
        if public_send("#{reflection.foreign_key}_changed?") 
          change_stack << [reflection.klass, 'update', public_send("#{reflection.foreign_key}_was")]
          change_stack << [reflection.klass, 'update', public_send(reflection.foreign_key)]
        end
      end
    end

    def pop_and_process_changes
      ActiveSupport::Notifications.instrument('poped_change_stack.change_detector', changes: @__change_stack) do
        reset_change_stack
      end
    end

    def reset_change_stack
      @__change_stack = nil
    end

    def change_stack
      @__change_stack ||= Set.new
    end

    def primary_key_value
      public_send self.class.primary_key
    end
  end
end
