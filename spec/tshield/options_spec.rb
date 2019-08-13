# frozen_string_literal: false

require 'optparse'
require 'tshield/options'
require 'spec_helper'

describe TShield::Options do
  context 'with parsing' do
    before :each do
      options_parser = double
      @opts = double

      allow(OptionParser).to receive(:new)
        .and_return(options_parser)
        .and_yield(@opts)

      allow(options_parser).to receive(:parse!)

      allow(@opts).to receive(:banner=)
      allow(@opts).to receive(:on)
      allow(@opts).to receive(:on_tail)
    end

    it 'should recover default port' do
      TShield::Options.init
      expect(TShield::Options.instance.port).to eql(4567)
    end

    it 'should recover custom port' do
      allow(@opts).to receive(:on)
        .with('-p', '--port [PORT]', 'Sinatra port')
        .and_yield('4568')

      TShield::Options.init
      expect(TShield::Options.instance.port).to eql(4568)
    end
  end
end
