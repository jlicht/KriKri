require 'spec_helper'

describe Krikri::Parser::ValueArray do
  subject { described_class.new(values) }
  let(:values) do
    vs = []
    3.times do |n|
      vs << double('value', :value => "value_#{n}")
    end
    vs
  end

  it 'is an Array' do
    expect(subject).to be_a Array
  end

  describe '.build' do
    let(:record) { instance_double(Krikri::Parser, :root => :root_node) }

    it 'builds with root node' do
      expect(described_class.build(record)).to contain_exactly(:root_node)
    end
  end

  describe '#values' do
    it 'gives values for items in array' do
      expect(subject.values).to eq ['value_0', 'value_1', 'value_2']
    end
  end

  describe '#field' do
    before do
      values.each do |val|
        nested_field = instance_double(Krikri::Parser::Value)
        allow(val).to receive(:[]).with(:field_name)
          .and_return(nested_field)
        allow(nested_field).to receive(:[]).with(:nested_name)
          .and_return(:final_value)
      end
    end

    it 'gives values from a field' do
      expect(subject.field(:field_name, :nested_name))
        .to contain_exactly(:final_value, :final_value, :final_value)
    end

    it 'returns an instance of its class' do
      expect(subject.field(:field_name)).to be_a described_class
    end
  end

  describe '#select' do
    it 'creates new array with selected values' do
      expect(subject.select { |v| v.value == 'value_1'})
        .to contain_exactly(values[1])
    end

    it 'returns an instance of its class' do
      expect(subject.select {}).to be_a described_class
    end
  end

  describe '#match_attribute' do
    before do
      values.each { |val| allow(val).to receive(:attribute?).and_return(false) }
    end


    it 'selects values by their attributes' do
      allow(values[0]).to receive(:attribute?).with(:type).and_return(true)
      allow(values[0]).to receive(:type).and_return('Moomin')
      allow(values[1]).to receive(:attribute?).with(:type).and_return(true)
      allow(values[1]).to receive(:type).and_return('mummi')
      expect(subject.match_attribute(:type, 'moomin'))
        .to contain_exactly(values[0])
    end
  end
end
