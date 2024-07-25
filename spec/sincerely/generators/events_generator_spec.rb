# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sincerely::Generators::EventsGenerator, type: :generator do
  include Rails::Generators::Testing::Assertions

  let(:connection) { double }

  tests(described_class)
  destination(File.join(Dir.tmpdir, 'files'))

  before do
    prepare_destination

    run_generator
  end

  context 'when running the generator' do
    it 'creates the migration file with the right content' do
      assert_migration('db/migrate/create_sincerely_delivery_events.rb') do |migration|
        expect(migration).to match(/create_table :sincerely_delivery_events/)
      end
    end

    it 'creates the base model file delivery events' do
      assert_file('app/models/sincerely/delivery_event.rb') do |content|
        expect(content).to match(/DeliveryEvent/)
      end
    end
  end
end
