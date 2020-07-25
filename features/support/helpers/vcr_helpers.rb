# frozen_string_literal: true

# VCR Helpes
class VCRHelpers
  EXAMPLES_SESSIONS = {
    'main-session' => {
      service: 'components',
      method: 'get',
      path: 'fake?t=saved-in-main-session',
      response: '{ "status": 200, "headers": {} }',
      body: 'expected content for main-session'
    },
    'second-session' => {
      service: 'components',
      method: 'get',
      path: 'fake?t=saved-in-second-session',
      response: '{ "status": 200, "headers": {} }',
      body: 'expected content for second-session'
    }
  }.freeze

  # Check VCRHelpers::EXAMPLES_SESSIONS for possible values
  def self.create_saved_session(session_name)
    values = VCRHelpers::EXAMPLES_SESSIONS[session_name]
    raise "#{session_name} not found in examples" unless values

    create_saved_session_files session_name, values[:service], values
  end

  # Check VCRHelpers::EXAMPLES_SESSIONS for possible values
  def self.response_for(session_name)
    values = VCRHelpers::EXAMPLES_SESSIONS[session_name]
    raise "#{session_name} not found in examples" unless values

    values[:body]
  end

  # - <name>/<service>/<path-with-params>/<method>
  # -- 0.json with the content like
  # { "status": 200, "headers": {} }
  # -- 0.content with the content like
  # {1: true, 2: false}
  def self.create_saved_session_files(session_name, service, content)
    destiny = File.join('component_tests', 'requests',
                        session_name, service, content[:path], content[:method])
    FileUtils.mkdir_p destiny

    write_in_file(destiny, '0.json', content[:response])
    write_in_file(destiny, '0.content', content[:body])
  end

  def self.write_in_file(destiny, name, content)
    file = File.open File.join(destiny, name), 'w'
    file.puts content
    file.close
  end
end
