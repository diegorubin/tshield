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
