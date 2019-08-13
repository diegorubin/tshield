# frozen_string_literal: true

require 'spec_helper'

require 'tshield/request_matching'

describe TShield::RequestMatching do
  before :each do
    @configuration = double
    allow(TShield::Configuration)
      .to receive(:singleton).and_return(@configuration)
  end

  context 'matching path' do
  end
end
