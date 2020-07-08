# frozen_string_literal: true

module TestServices
  class Service
    def self.rpc_descs
      { 'ServiceMethod' => {} }
    end
  end

  class Stub
    def initialize(attributes, options = {}); end
  end
end
