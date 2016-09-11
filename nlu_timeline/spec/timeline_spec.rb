require_relative 'spec_helper'
require 'timeline'
require 'awesome_print'

RSpec.describe NLU::Timeline do

  class DummyPerson
    include NLU::Timeline

    def new_name(counter)
      set_attribute(:name, "name#{counter}.2")
    end
  end

  let(:object1) { DummyPerson.new }
  let(:object2) { DummyPerson.new }

  before do
    NLU::Timeline::GlobalStore.reset
    object1.set_attribute(:name, 'name1.1')
    object2.set_attribute(:name, 'name2.1')

    object1.new_name(1)
    object2.new_name(2)
  end

  describe '#set_attribute' do
    it 'adds to the object attr storage' do
      expect(object1.timeline.to_h[0].name).to  eq 'name'
      expect(object1.timeline.to_h[0].value).to eq 'name1.1'
      expect(object1.timeline.to_h[1].name).to  eq 'name'
      expect(object1.timeline.to_h[1].value).to eq 'name1.2'

      expect(object2.timeline.to_h[0].name).to  eq 'name'
      expect(object2.timeline.to_h[0].value).to eq 'name2.1'
      expect(object2.timeline.to_h[1].name).to  eq 'name'
      expect(object2.timeline.to_h[1].value).to eq 'name2.2'
    end

    it 'adds to the global timeline' do
      global_store = NLU::Timeline::GlobalStore.inspect
      expect(NLU::Timeline::GlobalStore.inspect.count).to eq(4)

      expect(global_store[0].name).to      eq 'name'
      expect(global_store[0].value).to     eq 'name1.1'
      expect(global_store[0].object_id).to eq object1.object_id
      expect(global_store[1].name).to      eq 'name'
      expect(global_store[1].value).to     eq 'name2.1'
      expect(global_store[1].object_id).to eq object2.object_id
      expect(global_store[2].name).to      eq 'name'
      expect(global_store[2].value).to     eq 'name1.2'
      expect(global_store[2].object_id).to eq object1.object_id
      expect(global_store[3].name).to      eq 'name'
      expect(global_store[3].value).to     eq 'name2.2'
      expect(global_store[3].object_id).to eq object2.object_id
    end

    after do
      expect(NLU::Timeline::GlobalStore.inspect.count).to eq(4)
    end
  end

  describe '#attribute' do
    before do
      NLU::Timeline::GlobalStore.reset
    end

    it 'returns the current value' do
      expect(object1.attribute(:name)).to eq nil
      object1.set_attribute(:name, 'name1')
      expect(object1.attribute(:name)).to eq 'name1'
      object1.set_attribute(:name, 'name2')
      expect(object1.attribute(:name)).to eq 'name2'
    end
  end
end
