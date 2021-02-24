# frozen_string_literal: true

require 'tshield/controllers/requests'
require 'spec_helper'

# Class used to test helpers
class MockController
  include TShield::Controllers::Requests::Helpers
  def initialize(mock_logger)
    @mock_logger = mock_logger
  end

  def logger
    @mock_logger
  end

  def status(_value); end

  def headers(_value); end

  def body(_value); end
end

describe TShield::Controllers::Requests do
  before(:each) do
    @mock_logger = double
    @controller = MockController.new(@mock_logger)
    allow(TShield::Controllers::Helpers::SessionHelpers).to receive(:current_session_call)
  end
  context 'on treat request' do
    context 'on update session call' do
      it 'should call update_session_call with query params' do
        params = { 'captures' => ['/'] }

        request = double
        matcher = double
        matched_response = double

        allow(request).to receive(:request_method).and_return('GET')
        allow(request).to receive(:content_type).and_return('application/json')
        allow(request).to receive(:ip).and_return('0.0.0.0')
        allow(request).to receive(:env).and_return('QUERY_STRING' => 'a=b')
        allow(TShield::RequestMatching).to receive(:new).and_return(matcher)
        allow(matcher).to receive(:match_request).and_return(matched_response)
        allow(matched_response).to receive(:original).and_return(false)
        allow(matched_response).to receive(:status).and_return(200)
        allow(matched_response).to receive(:headers).and_return({})
        allow(matched_response).to receive(:body).and_return('')
        allow(@mock_logger).to receive(:info)

        expect(TShield::Controllers::Helpers::SessionHelpers)
          .to receive(:current_session_call).with(request, '/?a=b', 'GET')
        expect(TShield::Controllers::Helpers::SessionHelpers)
          .to receive(:update_session_call).with(request, '/?a=b', 'GET')

        @controller.treat(params, request, nil)
      end
    end
  end
end

describe TShield::Controllers::Requests do
  before :each do
    @configuration = double
    allow(TShield::Configuration)
      .to receive(:singleton).and_return(@configuration)
    allow(@configuration).to receive(:get_before_filters).and_return([])
    allow(@configuration).to receive(:not_save_headers).and_return([])
    allow(@configuration).to receive(:get_after_filters).and_return([])
    allow(@configuration).to receive(:get_headers).and_return([])
    allow(@configuration).to receive(:request).and_return('timeout' => 10)
    allow(@configuration).to receive(:get_name).and_return('example.org')
    allow(@configuration).to receive(:get_domain_for).and_return('example.org')
    allow(@configuration).to receive(:get_delay).and_return(0)


    allow(TShield::Options).to receive_message_chain(:instance, :break?)
    @mock_logger = double
    @controller = MockController.new(@mock_logger)
  end
  context 'when send_header_content_type is false for a single domain' do
    it 'should remove application/json header when making a request' do
      params = { 'captures' => ['/'] }
      request = double
      matcher = double
      matched_response = double

      allow(@configuration).to receive(:send_header_content_type).and_return(false)
      allow(request).to receive(:request_method).and_return('GET')
      allow(request).to receive(:content_type).and_return('application/json')
      allow(request).to receive(:ip).and_return('0.0.0.0')
      allow(request).to receive(:env).and_return('QUERY_STRING' => 'a=b')
      allow(TShield::RequestMatching).to receive(:new).and_return(matcher)
      allow(matcher).to receive(:match_request).and_return(nil)
      allow(TShield::RequestVCR).to receive(:new).and_return(matcher)
      allow(matcher).to receive(:vcr_response).and_return(matched_response)
      allow(matched_response).to receive(:original).and_return(false)
      allow(matched_response).to receive(:status).and_return(200)
      allow(matched_response).to receive(:headers).and_return({})
      allow(matched_response).to receive(:body).and_return('')
      allow(@mock_logger).to receive(:info)

      expect(TShield::RequestVCR).to receive(:new).with("/",{
        call: 0,
        headers: {},
        ip: "0.0.0.0",
        method: "GET",
        raw_query: "a=b",
        secondary_sessions: nil,
        session: nil
      })
      @controller.treat(params, request, nil)
    end
  end

  context 'when send_header_content_type is true for a single domain' do
    it 'should NOT remove application/json header when making a request' do
      params = { 'captures' => ['/'] }
      request = double
      matcher = double
      matched_response = double

      allow(@configuration).to receive(:send_header_content_type).and_return(true)
      allow(request).to receive(:request_method).and_return('GET')
      allow(request).to receive(:content_type).and_return('application/json')
      allow(request).to receive(:ip).and_return('0.0.0.0')
      allow(request).to receive(:env).and_return('QUERY_STRING' => 'a=b')
      allow(TShield::RequestMatching).to receive(:new).and_return(matcher)
      allow(matcher).to receive(:match_request).and_return(nil)
      allow(TShield::RequestVCR).to receive(:new).and_return(matcher)
      allow(matcher).to receive(:vcr_response).and_return(matched_response)
      allow(matched_response).to receive(:original).and_return(false)
      allow(matched_response).to receive(:status).and_return(200)
      allow(matched_response).to receive(:headers).and_return({})
      allow(matched_response).to receive(:body).and_return('')
      allow(@mock_logger).to receive(:info)

      expect(TShield::RequestVCR).to receive(:new).with("/",{
        call: 0,
        headers: {'Content-Type' => 'application/json'},
        ip: "0.0.0.0",
        method: "GET",
        raw_query: "a=b",
        secondary_sessions: nil,
        session: nil
      })


      @controller.treat(params, request, nil)
    end
  end
end
