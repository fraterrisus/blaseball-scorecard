require 'rspec'
require_relative '../../lib/at_bat'

describe AtBat do
  describe '#advance_to' do
    subject { described_class.new(id: '1') }

    before { subject.advance_to(target, :hit) }

    context 'normally' do
      let(:target) { 2 }

      it 'fills in all the base paths between here and there' do
        expect(subject.to_h[:paths]).to eq([:solid, :solid, nil, nil])
      end

      it 'fills in only the target base' do
        expect(subject.to_h[:bases]).to eq([nil, :solid, nil, nil])
      end

      it 'advances the current base' do
        expect(subject.current_base).to eq(target)
      end
    end
  end
end
