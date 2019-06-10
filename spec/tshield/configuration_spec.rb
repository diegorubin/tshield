# frozen_string_literal: true

require 'spec_helper'

describe TShield::Configuration do
  before :each do
    allow(File).to(
      receive(:join).and_return('spec/tshield/fixtures/config/tshield.yml')
    )
    @configuration = TShield::Configuration.singleton
  end

  describe 'load configurations from yaml' do
    it 'recover domains' do
      expect(@configuration.domains['example.org']['paths']).to(
        include('/api/one', '/api/two')
      )
    end
  end

  describe 'get_domain_for' do
    it 'return domain for example.org' do
      expect(@configuration.get_domain_for('/api/two')).to eq('example.org')
    end

    it 'return domain for example.com' do
      expect(@configuration.get_domain_for('/api/three')).to eq('example.com')
    end

    it 'return nil if domain not found' do
      expect(@configuration.get_domain_for('/api/four')).to be_nil
    end
  end
end
