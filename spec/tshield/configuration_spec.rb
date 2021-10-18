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

      it 'recover skip query params' do
        expect(@configuration.domains['example.org']['skip_query_params']).to(
          include('a')
        )
      end

      context 'on grpc configuration' do
        it 'recover server port' do
          expect(@configuration.grpc['port']).to(eq(5678))
        end
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

    describe 'SO compatibility' do
      it 'should be compatible with windows when configuration is true' do
        allow(YAML).to receive(:safe_load).and_return({ windows_compatibility: true })
        TShield::Configuration.clear
        @configuration = TShield::Configuration.singleton

        expect(@configuration.windows_compatibility?).to eq(true)
      end

      it 'should be compatible with Unix when configuration is false' do
        allow(YAML).to receive(:safe_load).and_return({ windows_compatibility: false })
        TShield::Configuration.clear
        @configuration = TShield::Configuration.singleton

        expect(@configuration.windows_compatibility?).to eq(false)
      end

      it 'should be compatible with Unix when configuration is missing' do
        allow(YAML).to receive(:safe_load).and_return({})
        TShield::Configuration.clear
        @configuration = TShield::Configuration.singleton

        expect(@configuration.windows_compatibility?).to eq(false)
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

  context 'on config exists without grpc entry' do
    before :each do
      @configuration = generate_configuration_from_file('spec/tshield/fixtures/config/tshield-without-grpc.yml')
      TShield::Configuration.clear
    end
    it 'should set default value for port' do
      expect(@configuration.grpc).to eql('port' => 5678, 'proto_dir' => 'proto', 'services' => {})
    end
  end

  context 'on config property request.domains.domain.send_header_content_type does not exists' do
    before :each do
      @configuration = generate_configuration_from_file('spec/tshield/fixtures/config/tshield-without-grpc.yml')
      TShield::Configuration.clear
    end
    it 'should return send_header_content_type as true when property is not set' do
      expect(@configuration.send_header_content_type('example.org')).to be true
    end
  end

  context 'on config property request.domains.domain.send_header_content_type does exists' do
    before :each do
      TShield::Configuration.clear
    end
    it 'should return send_header_content_type as true when property is true' do
      @configuration = generate_configuration_from_file('spec/tshield/fixtures/config/tshield-with-send-content-type-header.yml')
      expect(@configuration.send_header_content_type('example.org')).to be true
    end
    it 'should return send_header_content_type as false when property is false' do
      @configuration = generate_configuration_from_file('spec/tshield/fixtures/config/tshield-with-send-content-type-header_as_false.yml')
      expect(@configuration.send_header_content_type('example.org')).to be false
    end
  end
end

def generate_configuration_from_file(file)
  options_instance = double
  allow(options_instance).to receive(:configuration_file).and_return(file)
  allow(TShield::Options).to receive(:instance).and_return(options_instance)
  TShield::Configuration.singleton
end
