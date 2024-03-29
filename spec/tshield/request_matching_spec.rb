# frozen_string_literal: true

require 'spec_helper'

require 'tshield/configuration'
require 'tshield/request_matching'
require 'tshield/response'

describe TShield::RequestMatching do
  before :each do
    @configuration = double
    TShield::RequestMatching.clear_stubs
    allow(TShield::Configuration)
      .to receive(:singleton).and_return(@configuration)
  end

  context 'on empty matching path' do
    before :each do
      allow(Dir).to receive(:glob)
        .and_return([])
    end

    it 'should return empty response when called' do
      request_matching = TShield::RequestMatching.new('/')
      expect(request_matching.match_request).to be_nil
    end

    it 'should return empty response when called via post' do
      request_matching = TShield::RequestMatching.new('/', method: 'POST')
      expect(request_matching.match_request).to be_nil
    end

    it 'should return empty response when called via post and in session' do
      request_matching = TShield::RequestMatching.new('/', method: 'POST', session: 'session')
      expect(request_matching.match_request).to be_nil
    end
  end

  context 'invalid matching file' do
    before :each do
      allow(Dir).to receive(:glob)
        .and_return(['spec/tshield/fixtures/matching/invalid_matching_file.json'])
    end

    context 'on loading stubs' do
      before :each do
        @request_matching = TShield::RequestMatching.new('/')
      end
      it 'should stubs be empty' do
        expect(@request_matching.class.stubs[DEFAULT_SESSION]).to be_nil
      end
    end
  end

  context 'empty matching file' do
    before :each do
      allow(Dir).to receive(:glob)
        .and_return(['spec/tshield/fixtures/matching/empty.json'])
    end

    context 'on loading stubs' do
      before :each do
        @request_matching = TShield::RequestMatching.new('/')
      end
      it 'should stubs be empty' do
        expect(@request_matching.class.stubs[DEFAULT_SESSION]).to be_nil
      end
    end
  end

  context 'matching path' do
    before :each do
      allow(Dir).to receive(:glob)
        .and_return(['spec/tshield/fixtures/matching/example.json'])
    end

    context 'on loading stubs' do
      before :each do
        @request_matching = TShield::RequestMatching.new('/')
      end
      context 'for path /matching/example' do
        it 'should map path' do
          expect(@request_matching.class.stubs[DEFAULT_SESSION]).to include('/matching/example')
        end
        context 'on settings' do
          before :each do
            @entry = @request_matching.class.stubs[DEFAULT_SESSION]['/matching/example'][0]
          end
          it 'should answer for the method GET' do
            expect(@entry['method']).to include('GET')
          end
          it 'should have response body' do
            expect(@entry['response']['body']).to include('query content')
          end
        end
      end
    end

    context 'on matching request' do
      context 'on match' do
        before :each do
          @request_matching = TShield::RequestMatching.new('/matching/example', method: 'GET')
        end
        it 'should return response object' do
          @response = @request_matching.match_request
          expect(@response.body).to eql('body content')
          expect(@response.headers).to eql({})
          expect(@response.status).to eql(200)
        end
      end
      context 'on match by path and method' do
        before :each do
          @request_matching = TShield::RequestMatching
                              .new('/matching/example', method: 'POST')
        end
        it 'should return response object' do
          @response = @request_matching.match_request
          expect(@response.body).to eql('post content')
          expect(@response.headers).to eql({})
          expect(@response.status).to eql(201)
        end
      end
      context 'on match by path and method and headers' do
        before :each do
          @request_matching = TShield::RequestMatching
                              .new('/matching/example',
                                   method: 'POST',
                                   headers: { 'HTTP_HEADER1' => 'value' })
        end
        it 'should return response object' do
          @response = @request_matching.match_request
          expect(@response.body).to eql('headers content')
          expect(@response.headers).to eql({})
          expect(@response.status).to eql(201)
        end
      end
      context 'on match by path and returns json' do
        before :each do
          @request_matching = TShield::RequestMatching
                              .new('/matching/example.json', method: 'GET')
        end
        it 'should return response object' do
          @response = @request_matching.match_request
          expect(@response.body).to eql('{"json":"content"}')
          expect(@response.headers).to eql('Content-Type' => 'application/json')
          expect(@response.status).to eql(200)
        end
      end
      context 'on match by path and method and query' do
        before :each do
          @request_matching = TShield::RequestMatching
                              .new('/matching/example',
                                   method: 'GET',
                                   raw_query: 'query1=value')
        end
        it 'should return response object' do
          @response = @request_matching.match_request
          expect(@response.body).to eql('query content')
          expect(@response.headers).to eql({})
          expect(@response.status).to eql(200)
        end
      end
      context 'on match have multiples responses' do
        before :each do
          @responses = []
          3.times.each do |time|
            @responses << TShield::RequestMatching
                          .new('/matching/twice',
                               method: 'GET',
                               call: time).match_request
          end
        end

        it 'should return response object in first call' do
          response = @responses[0]
          expect(response.body).to eql('first call')
          expect(response.headers).to eql('try' => 1)
          expect(response.status).to eql(200)
        end

        it 'should return response object in second call' do
          response = @responses[1]
          expect(response.body).to eql('second call')
          expect(response.headers).to eql('try' => 2)
          expect(response.status).to eql(201)
        end

        it 'should return first response object in third call' do
          response = @responses[2]
          expect(response.body).to eql('first call')
          expect(response.headers).to eql('try' => 1)
          expect(response.status).to eql(200)
        end
      end
      context 'on match have file reference' do
        before :each do
          request_matching = TShield::RequestMatching
                             .new('/matching/file.txt',
                                  method: 'GET')

          file_content_double = double
          allow(File).to receive(:join).with('matching', 'body.json')
                                       .and_return('matching/body.json')
          allow(File).to receive(:open).with('matching/body.json', 'r')
                                       .and_return(file_content_double)

          allow(file_content_double).to receive(:read).and_return("line1\nline2")

          @response = request_matching.match_request
        end

        it 'should return content of file' do
          expect(@response.body).to eql("line1\nline2")
          expect(@response.headers).to eql({})
          expect(@response.status).to eql(200)
        end
      end
      context 'on match with regex' do
        before :each do
          @response = request_matching = TShield::RequestMatching
                                         .new('/matching/regex/1234',
                                              method: 'GET').match_request
        end

        it 'should return content of file' do
          expect(@response.body).to eql('stub with regex')
          expect(@response.headers).to eql({})
          expect(@response.status).to eql(200)
        end
      end

      context 'on not match' do
        before :each do
          @request_matching = TShield::RequestMatching.new('/')
        end
        it 'should return nil' do
          expect(@request_matching.match_request).to be_nil
        end
      end
    end
    context 'on session' do
      context 'load session infos' do
        before :each do
          @request_matching = TShield::RequestMatching.new('/')
        end

        it 'should map path' do
          expect(@request_matching.class.stubs['a-session']).to include('/matching/example')
        end
      end
      context 'on match' do
        it 'should return response object from session settings' do
          @request_matching = TShield::RequestMatching.new('/matching/example',
                                                           method: 'GET',
                                                           session: 'a-session')
          @response = @request_matching.match_request
          expect(@response.body).to eql('body content in session')
          expect(@response.headers).to eql({})
          expect(@response.status).to eql(200)
        end
        it 'should return response object from default settings' do
          @request_matching = TShield::RequestMatching.new('/matching/example',
                                                           method: 'POST',
                                                           session: 'a-session')
          @response = @request_matching.match_request
          expect(@response.body).to eql('post content')
          expect(@response.headers).to eql({})
          expect(@response.status).to eql(201)
        end
        context 'with secondary session' do
          it 'should return response object from session settings' do
            @request_matching = TShield::RequestMatching.new('/matching/second-example',
                                                             method: 'GET',
                                                             session: 'a-session',
                                                             secondary_sessions: ['second-session'])
            @response = @request_matching.match_request
            expect(@response.body).to eql('body content in second-session')
            expect(@response.headers).to eql({})
            expect(@response.status).to eql(200)
          end
        end
      end
    end
  end
end
