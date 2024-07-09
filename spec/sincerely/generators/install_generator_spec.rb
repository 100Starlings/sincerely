# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sincerely::Generators::InstallGenerator do
  include GeneratorSpec::TestCase

  tests(described_class)
  destination(File.join(Dir.tmpdir, 'files'))

  before do
    prepare_destination
  end

  context 'when executing the install generator' do
    context "when the file doesn't exist" do
      before do
        run_generator
      end

      it 'creates the initializer file with the right content' do
        assert_file('config/sincerely.yml') do |content|
          expect(content).to match(/model_name: Notification/)
        end
      end
    end
  end
end
