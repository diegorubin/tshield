# frozen_string_literal: true

require 'spec_helper'

require 'tshield/request'

describe TShield::Request do
  before :each do
    @configuration = double
    allow(TShield::Configuration)
      .to receive(:singleton).and_return(@configuration)
    allow(@configuration).to receive(:get_before_filters).and_return([])
    allow(@configuration).to receive(:get_after_filters).and_return([])
    allow(@configuration).to receive(:request).and_return('timeout' => 10)
    allow(@configuration).to receive(:get_domain_for).and_return('example.org')
    allow(TShield::Options).to receive_message_chain(:instance, :break?)
  end

  describe 'when save response' do
    it 'should write response body, request status and headers' do
      allow_any_instance_of(TShield::Request).to receive(:exists)
        .and_return(false)
      allow_any_instance_of(TShield::Request).to receive(:destiny)
      allow(HTTParty).to receive(:send).and_return(RawResponse.new)

      write_spy = double
      allow(File).to receive(:open).and_return(write_spy)

      expect(write_spy).to receive(:write).ordered.with('this is the body')
      expect(write_spy).to receive(:write)
        .ordered
        .with("{\n  \"status\": 200,\n  \"headers\": {\n  }\n}")
      allow(write_spy).to receive(:close)

      TShield::Request.new '/', method: 'GET'
    end

    describe 'and query params exists in list to skip' do
      before :each do
        allow(@configuration).to receive(:get_name).and_return('example.org')
        allow(@configuration).to receive(:cache_request?).and_return(true)
        allow(File).to receive(:join).with('requests')
                                     .and_return('./requests')
        allow(File).to receive(:join).with('./requests', 'example.org')
                                     .and_return('./requests/example.org')
      end

      it 'should create response directory without query param' do
        allow(File).to receive(:join)
          .with('./requests/example.org', '?allowed=true')
          .and_return('./requests/example.org/?allowed=true')
        allow(File).to receive(:join)
          .with('./requests/example.org/?allowed=true', 'get')
          .and_return('./requests/example.org/?allowed=true/get')
        allow(File).to receive(:join)
          .with('./requests/example.org/?allowed=true/get', '0.json')
          .and_return('./requests/example.org/?allowed=true/get/0.json')
        allow(File).to receive(:join)
          .with('./requests/example.org/?allowed=true/get', '0.content')
          .and_return('./requests/example.org/?allowed=true/get/0.content')

        allow(@configuration).to receive(:domains).and_return(
          'example.org' => {
            'skip_query_params' => ['skipped']
          }
        )

        allow(HTTParty).to receive(:send).and_return(RawResponse.new)
        read_double = double

        allow(read_double).to receive(:read).and_return('{}')
        expect(File).to receive('open')
          .with('./requests/example.org/?allowed=true/get/0.json')
          .and_return(read_double)
        expect(File).to receive('open')
          .with('./requests/example.org/?allowed=true/get/0.content')
          .and_return(read_double)

        TShield::Request.new '/',
                             raw_query: 'allowed=true&skipped=1',
                             method: 'GET'
      end
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
