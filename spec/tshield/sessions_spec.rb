# frozen_string_literal: true

require 'tshield/sessions'
require 'spec_helper'

describe TShield::Sessions do
  context 'on append session' do
    it 'should raise error if not has a main session' do
      expect { TShield::Sessions.append 'ip', 'secondary-session' }
        .to raise_error(AppendSessionWithoutMainSessionError)
    end
    it 'should append if has main session' do
      TShield::Sessions.start 'ip', 'main-session'
      result = TShield::Sessions.append 'ip', 'secondary-session'
      expect(result[:secondary_sessions]).to include('secondary-session')
    end
  end
end
