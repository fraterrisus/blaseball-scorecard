require 'rspec'
require_relative '../lib/at_bat'

describe AtBat do
  describe '#advance_to' do
    subject { described_class.new(id: 'test') }

    before do
      subject.send(:update_corner_text, 'test')
      subject.advance_to(target, type)
    end

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
      it { is_expected.to not_overwrite_corner_text }
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
      it { is_expected.to not_overwrite_corner_text }
    end
  end

  describe '#ball' do
    subject { described_class.new(id: 'test') }

    before { subject.send(:update_corner_text, 'test') }

    context 'first pitch' do
      before { subject.ball }
      it { is_expected.to set_balls_to :hollow }
      it { is_expected.to be_at :home }
      it { is_expected.to not_overwrite_corner_text }
    end

    context 'after four balls' do
      before { 4.times { subject.ball } }
      it { is_expected.to set_balls_to :hollow, :hollow, :hollow, :hollow }
      it { is_expected.to be_at :home }
      it { is_expected.to not_overwrite_corner_text }
    end
  end

  describe '#caught_stealing' do
    subject { described_class.new(id: 'test') }

    before do
      subject.send(:update_corner_text, 'test')
      subject.caught_stealing(1)
    end

    it { expect(path_h_1).to be_nil }
    it { expect(first_base).to be :crossed_circled }
    it { is_expected.to be_out }
    it { is_expected.to not_overwrite_corner_text }
  end

  describe '#double_play' do
    subject { described_class.new(id: 'test') }

    before do
      subject.send(:update_corner_text, 'test')
      subject.double_play
    end

    # We expect the caller to apply diffs because multiple runners must be accounted for
    it { is_expected.to set_bases_to nil, nil, nil, nil }
    it { is_expected.to set_paths_to nil, nil, nil, nil }

    it { is_expected.to be_out }
    it { is_expected.to be_at :home }
    it { is_expected.to set_corner_text_to '2P' }
  end

  describe '#fly_out_to' do
    pending
  end

  describe '#ground_out_to' do
    pending
  end

  describe '#out_at' do
    pending
  end

  describe '#sacrifice' do
    pending
  end

  describe '#strike' do
    pending
  end

  describe '#strikeout' do
    pending
  end

  describe '#triple_play' do
    subject { described_class.new(id: 'test') }

    before do
      subject.send(:update_corner_text, 'test')
      subject.triple_play
    end

    # We expect the caller to apply diffs because multiple runners must be accounted for
    it { is_expected.to set_bases_to nil, nil, nil, nil }
    it { is_expected.to set_paths_to nil, nil, nil, nil }

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
      @actual = case actual.current_base
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
      values_match? @actual, expected
    end
    diffable
  end

  %w(balls bases paths strikes).each do |field|
    RSpec::Matchers.define "set_#{field}_to".to_sym do |*expected|
      match do |actual|
        @actual = actual.to_h[field.to_sym]
        values_match? expected, @actual
      end
      diffable
    end
  end

  RSpec::Matchers.define :set_center_text_to do |expected|
    match do |actual|
      @actual = actual.to_h[:center_text]
      values_match? expected, @actual
    end
    diffable
  end

  RSpec::Matchers.define :not_overwrite_corner_text do
    match do |actual|
      @actual = actual.to_h[:corner_text]
      values_match? 'test', @actual
    end
    diffable
  end

  RSpec::Matchers.define :set_corner_text_to do |expected|
    match do |actual|
      @actual = actual.to_h[:corner_text]
      values_match? expected, @actual
    end
    diffable
  end
end
