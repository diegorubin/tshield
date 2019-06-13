# frozen_string_literal: true

require 'spec_helper'

require 'tshield/request'

describe TShield::Request do
  before :each do
    @configuration = TShield::Configuration.singleton
    @configuration.stub(:get_before_filters).and_return([])
    @configuration.stub(:get_after_filters).and_return([])
    TShield::Options.stub_chain(:instance, :break?)
  end

  describe 'when save response' do
    it 'should write response body, request status and headers' do
      TShield::Request.any_instance.stub(:exists).and_return(false)
      TShield::Request.any_instance.stub(:destiny)
      HTTParty.stub(:send).and_return(RawResponse.new)

      writeSpy = double
      File.stub(:open).and_return(writeSpy)

      writeSpy.should_receive(:write).ordered.with('this is the body')
      writeSpy.should_receive(:write).ordered.with("{\n  \"status\": 200,\n  \"headers\": {\n  }\n}")
      allow(writeSpy).to receive(:close)

      TShield::Request.new '/', {method: 'GET'}
    end
  end

  class RawResponse
    def headers
      []
    end

    def body
      'this is the body'
    end

    def code
      200
    end
  end
end
