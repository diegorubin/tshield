# frozen_string_literal: false

require 'tshield/configuration'
require 'spec_helper'

describe TShield::Configuration do
  context 'on config exist' do
    before :each do
      options_instance = double
      allow(options_instance).to receive(:configuration_file)
        .and_return('spec/tshield/fixtures/config/tshield.yml')
      allow(TShield::Options).to receive(:instance).and_return(options_instance)
      allow(File).to receive(:join).and_return(
        './spec/tshield/fixtures/filters/example_filter.rb'
      )
      allow(File).to receive(:exist?) do
        true
      end
      allow(Dir).to receive(:entries) do
        ['.', '..', 'example_filter.rb']
      end
      @configuration = TShield::Configuration.singleton
    end

    context 'load configurations from yaml' do
      it 'recover domains' do
        expect(@configuration.domains['example.org']['paths']).to(
          include('/api/one', '/api/two')
        )
      end

      context 'on load filters' do
        it 'recover filters for a domain' do
          expect(@configuration.get_filters('example.org')).to eq([ExampleFilter])
        end
        it 'return empty array if domain not have filters' do
          expect(@configuration.get_filters('example.com')).to eq([])
        end
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
  context 'on config not exist' do
    before :each do
      options_instance = double
      allow(options_instance).to receive(:configuration_file)
        .and_return('not_found/config/tshield.yml')
      allow(TShield::Options).to receive(:instance).and_return(options_instance)
      TShield::Configuration.clear
    end

    it 'exit with error status' do
      expect { TShield::Configuration.singleton }.to raise_error RuntimeError
    end
  end
end
