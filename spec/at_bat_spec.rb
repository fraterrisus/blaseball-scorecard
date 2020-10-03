require 'rspec'
require_relative '../lib/at_bat'

describe AtBat do
  subject { described_class.new(id: 'test') }

  before { subject.send(:update_corner_text, 'test') }

  describe '#advance_to' do
    before { subject.advance_to(target, type) }

    let(:target) { 1 }
    let(:type) { :hit }

    context 'when advancing one base' do
      let(:target) { 1 }

      it 'fills in first path' do
        expect(path_h_1).to_not be_nil
        expect(path_1_2).to be_nil
        expect(path_2_3).to be_nil
        expect(path_3_h).to be_nil
      end

      it 'fills in first base' do
        expect(first_base).to_not be_nil
        expect(second_base).to be_nil
        expect(third_base).to be_nil
        expect(home_plate).to be_nil
      end

      it { is_expected.to_not be_out }
      it { is_expected.to be_at :first }
    end

    context 'when advancing three bases' do
      let(:target) { 3 }

      it 'fills in all the paths between here and there' do
        expect(path_h_1).to_not be_nil
        expect(path_1_2).to_not be_nil
        expect(path_2_3).to_not be_nil
        expect(path_3_h).to be_nil
      end

      it 'fills in only the target base' do
        expect(first_base).to be_nil
        expect(second_base).to be_nil
        expect(third_base).to_not be_nil
        expect(home_plate).to be_nil
      end

      it { is_expected.to_not be_out }
      it { is_expected.to be_at :third }
    end

    context 'when advancing on a hit' do
      let(:type) { :hit }

      it { expect(path_h_1).to be :solid }
      it { expect(first_base).to be :solid }
      it { is_expected.to_not be_out }
      it { is_expected.to_not be_at :home }
      it { is_expected.to not_set_corner_text }
    end

    context "when advancing on a fielder's choice" do
      let(:type) { :fielders_choice }

      it { expect(path_h_1).to be :solid }
      it { expect(first_base).to be :hollow }
      it { is_expected.to_not be_out }
      it { is_expected.to_not be_at :home }
      it { is_expected.to set_corner_text_to 'FC' }
    end

    context 'when advancing on a walk' do
      let(:type) { :walk }

      it { expect(path_h_1).to be :solid }
      it { expect(first_base).to be :hollow }
      it { is_expected.to_not be_out }
      it { is_expected.to_not be_at :home }
      it { is_expected.to set_corner_text_to 'BB' }
    end

    context 'when advancing on a multi-base walk' do
      let(:type) { :walk }
      let(:target) { 2 }

      it do
        expect(path_h_1).to be :solid
        expect(path_1_2).to be :solid
      end

      it do
        expect(first_base).to be_nil
        expect(second_base).to be :hollow
      end

      it { is_expected.to_not be_out }
      it { is_expected.to be_at :second }
    end

    context 'when advancing on a stolen base' do
      let(:type) { :stolen_base }

      it { expect(path_h_1).to be :hashed }
      it { expect(first_base).to be :solid }
      it { is_expected.to_not be_out }
      it { is_expected.to_not be_at :home }
      it { is_expected.to not_set_corner_text }
    end
  end

  describe '#ball' do
    context 'first pitch' do
      before { subject.ball }

      it { is_expected.to set_balls_to :hollow }
      it { is_expected.to be_at :home }
      it { is_expected.to not_set_corner_text }
    end

    context 'after four balls' do
      before { 4.times { subject.ball } }
      it { is_expected.to set_balls_to :hollow, :hollow, :hollow, :hollow }

      it 'does not automatically apply a walk' do
        is_expected.to be_at :home
        is_expected.to not_set_corner_text
      end
    end
  end

  describe '#caught_stealing' do
    before { subject.caught_stealing(1) }

    it { expect(path_h_1).to be_nil }
    it { expect(first_base).to be :crossed_circled }
    it { is_expected.to be_out }
    it { is_expected.to not_set_corner_text }
  end

  describe '#double_play' do
    before { subject.double_play }

    it 'expects the caller to apply base/path diffs' do
      is_expected.to set_bases_to nil, nil, nil, nil
      is_expected.to set_paths_to nil, nil, nil, nil
    end

    it { is_expected.to be_out }
    it { is_expected.to be_at :home }
    it { is_expected.to set_corner_text_to '2P' }
  end

  describe '#fly_out_to' do
    before { subject.fly_out_to(5) }

    it 'expects the caller to apply base/path diffs' do
      is_expected.to set_bases_to nil, nil, nil, nil
      is_expected.to set_paths_to nil, nil, nil, nil
    end

    it { is_expected.to be_out }
    it { is_expected.to be_at :home }
    it { is_expected.to set_center_text_to '5', :circled }
    it { is_expected.to not_set_corner_text }
  end

  describe '#ground_out_to' do
    before { subject.ground_out_to(5) }

    it { expect(first_base).to be :crossed }
    it { expect(path_h_1).to be_nil }
    it { is_expected.to be_out }
    it { is_expected.to be_at :home }
    it { is_expected.to set_center_text_to '5' }
    it { is_expected.to not_set_corner_text}
  end

  describe '#out_at' do
    before { subject.out_at(target) }

    context 'when out at the next base' do
      let(:target) { 1 }

      it { expect(first_base).to be :crossed }
      it { expect(path_h_1).to be_nil }
      it { is_expected.to be_out }
      it { is_expected.to be_at :home }
      it { is_expected.to not_set_corner_text }
    end

    context 'when out at a further base' do
      let(:target) { 2 }

      it { expect(first_base).to be nil }
      it { expect(second_base).to be :crossed }
      it { expect(path_h_1).to be_nil }
      it { expect(path_1_2).to be_nil }
      it { is_expected.to be_out }
      it { is_expected.to be_at :home }
    end
  end

  describe '#sacrifice' do
    before { subject.sacrifice }

    it 'expects the caller to apply base/path diffs' do
      is_expected.to set_bases_to nil, nil, nil, nil
      is_expected.to set_paths_to nil, nil, nil, nil
    end

    it { is_expected.to be_out }
    it { is_expected.to be_at :home }
    it { is_expected.to set_center_text_to :squared }
    it { is_expected.to not_set_corner_text }
  end

  describe '#strike' do
    context 'for a swinging strike' do
      before { subject.strike(:swinging) }

      it { is_expected.to set_strikes_to :solid }
      it { is_expected.to_not be_out }
      it { is_expected.to be_at :home }
      it { is_expected.to not_set_center_text }
    end

    context 'for a looking strike' do
      before { subject.strike(:looking) }

      it { is_expected.to set_strikes_to :hollow }
      it { is_expected.to_not be_out }
      it { is_expected.to be_at :home }
      it { is_expected.to not_set_center_text }
    end

    context 'for a foul ball' do
      before { subject.strike(:foul_ball) }

      it { is_expected.to set_strikes_to :crossed }
      it { is_expected.to_not be_out }
      it { is_expected.to be_at :home }
      it { is_expected.to not_set_center_text }
    end

    context 'for four strikes' do
      before { 4.times { subject.strike(:swinging) } }

      it { is_expected.to set_strikes_to :solid, :solid, :solid, :solid }

      it 'does not automatically register the strikeout' do
        is_expected.to_not be_out
        is_expected.to be_at :home
        is_expected.to not_set_center_text
      end
    end
  end

  describe '#strikeout' do
    context 'when the last strike was looking' do
      before do
        subject.strike(:looking)
        subject.strikeout
      end

      it { is_expected.to be_out }
      it { is_expected.to be_at :home }
      it { is_expected.to set_center_text_to 'K', :reversed }
      it { is_expected.to not_set_corner_text }
    end

    context 'when the last strike was not looking' do
      before do
        subject.strike(:foul_ball)
        subject.strikeout
      end

      it { is_expected.to be_out }
      it { is_expected.to be_at :home }
      it { is_expected.to set_center_text_to 'K' }
      it { is_expected.to not_set_corner_text }
    end
  end

  describe '#triple_play' do
    before { subject.triple_play }

    it 'expects the caller to apply base/path diffs' do
      is_expected.to set_bases_to nil, nil, nil, nil
      is_expected.to set_paths_to nil, nil, nil, nil
    end

    it { is_expected.to be_out }
    it { is_expected.to be_at :home }
    it { is_expected.to set_corner_text_to '3P' }
  end

  ##### ##### ##### ##### #####

  def first_base
    subject.to_h[:bases][0]
  end

  def second_base
    subject.to_h[:bases][1]
  end

  def third_base
    subject.to_h[:bases][2]
  end

  def home_plate
    subject.to_h[:bases][3]
  end

  def path_h_1
    subject.to_h[:paths][0]
  end

  def path_1_2
    subject.to_h[:paths][1]
  end

  def path_2_3
    subject.to_h[:paths][2]
  end

  def path_3_h
    subject.to_h[:paths][3]
  end

  RSpec::Matchers.define :be_at do |expected|
    match do |actual|
      actual_base = case actual.current_base
      when 0,4
        :home
      when 1
        :first
      when 2
        :second
      when 3
        :third
      else
        nil
      end
      values_match? actual_base, expected
    end
    diffable
  end

  %w(balls bases paths strikes).each do |field|
    RSpec::Matchers.define "set_#{field}_to".to_sym do |*expected|
      match do |actual|
        values_match? expected, actual.to_h[field.to_sym]
      end
      diffable
    end
  end

  RSpec::Matchers.define :not_set_center_text do
    match do |actual|
      actual.to_h[:center_text].nil?
    end
  end

  RSpec::Matchers.define :set_center_text_to do |*expected|
    match do |actual|
      values_match? expected, Array(actual.to_h[:center_text])
    end
    diffable
  end

  RSpec::Matchers.define :not_set_corner_text do
    match do |actual|
      values_match? 'test', actual.to_h[:corner_text]
    end
  end

  RSpec::Matchers.define :set_corner_text_to do |*expected|
    match do |actual|
      values_match? expected, Array(actual.to_h[:corner_text])
    end
    diffable
  end
end
