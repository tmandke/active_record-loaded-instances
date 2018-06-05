require 'spec_helper'

RSpec.describe ActiveRecord::ChangeDetector do
  describe '#stack_changes' do
    context 'with user' do
      let(:user) { User.new(name: 'buya') }

      it 'created sends create event for the user' do
        change_events = capture_change_events do
          user.save!
        end
        expect(change_events).to eq([{ changes: [[User, 'create', user.id]].to_set }])
      end

      it 'updated sends update event for the user' do
        user.save!
        change_events = capture_change_events do
          user.update_attributes name: '111'
        end
        expect(change_events).to eq([{ changes: [[User, 'update', user.id]].to_set }])
      end

      it 'destroyed sends destroy event for the user' do
        user.save!
        change_events = capture_change_events do
          user.destroy
        end
        expect(change_events).to eq([{ changes: [[User, 'destroy', user.id]].to_set }])
      end

      it 'failed create creates no events' do
        change_events = capture_change_events do
          user.name = nil
          user.save rescue nil
        end
        expect(change_events).to eq([])
      end

      it 'failed update creates no events' do
        user.save
        change_events = capture_change_events do
          user.name = nil
          user.save rescue nil
        end
        expect(change_events).to eq([])
      end
    end
  end

  def capture_change_events
    change_events = []
    ActiveSupport::Notifications.subscribe('poped_change_stack.change_detector') do |name, start, finish, id, payload|
      change_events << payload
    end
    yield
    change_events
  end
end
