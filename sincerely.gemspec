# frozen_string_literal: true

require_relative 'lib/sincerely/version'

Gem::Specification.new do |spec|
  spec.name = 'sincerely'
  spec.version = Sincerely::VERSION
  spec.authors = ['100 Starlings']
  spec.email = ['rubyblok@100starlings.com']

  spec.summary = 'Notifications'
  spec.homepage = 'http://www.rubyblok.com'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/100Starlings/sincerely'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'aasm', '~> 5.3'
  spec.add_dependency 'anyway_config', '>= 2.6.0'
  spec.add_dependency 'liquid', '>= 5.5'
  spec.add_dependency 'railties', '>= 6'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
