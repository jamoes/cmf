require 'spec_helper'

describe CMF::Dictionary do
  describe '#validate' do
    it 'validates nil dictionary' do
      expect(CMF::Dictionary.validate(nil)).to eq({})
    end

    it 'validates array dictionary' do
      expect(CMF::Dictionary.validate([:tag0, :tag1, :tag2])).to eq({tag0: 0, tag1: 1, tag2: 2})
    end

    it 'validates hash dictionary' do
      expect(CMF::Dictionary.validate({tag0: 0, tag1: 1, tag2: 2})).to eq({tag0: 0, tag1: 1, tag2: 2})
    end

    it 'does not allow integer keys' do
      expect { CMF::Dictionary.validate({100 => 0, tag1: 1}) }.to raise_error(TypeError)
    end

    it 'requires integer values' do
      expect { CMF::Dictionary.validate({tag0: 0, tag1: "foo"}) }.to raise_error(TypeError)
    end

    it 'does not allow duplicate values' do
      expect { CMF::Dictionary.validate({tag0: 0, tag1: 0}) }.to raise_error(ArgumentError)
    end

    it 'does not allow duplicate values' do
      expect { CMF::Dictionary.validate({tag0: 0, tag1: 0}) }.to raise_error(ArgumentError)
    end

  end
end
