# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sincerely::Generators::MigrationGenerator, type: :generator do
  include Rails::Generators::Testing::Assertions

  let(:name) { 'notification' }
  let(:connection) { double }

  tests(described_class)
  destination(File.join(Dir.tmpdir, 'files'))

  shared_examples 'a template generator' do
    it 'creates the template migration file with the right content' do
      assert_migration("db/migrate/create_#{name}_templates.rb") do |migration|
        expect(migration).to match(/create_table :notification_templates/)
      end
    end

    it 'creates the template model file' do
      assert_file("app/models/#{name}_template.rb") do |content|
        expect(content).to match(/NotificationTemplate/)
      end
    end
  end

  before do
    allow(connection).to receive(:table_exists?).and_return(table_exists)
    allow(ActiveRecord::Base).to receive(:connection).and_return(connection)

    prepare_destination

    run_generator([name])
  end

  context "when the table doesn't exist" do
    let(:table_exists) { false }

    it_behaves_like 'a template generator'

    it 'creates the migration file with the right content' do
      assert_migration("db/migrate/create_#{name.pluralize}.rb") do |migration|
        expect(migration).to match(/create_table :notifications/)
      end
    end

    it 'creates the model file' do
      assert_file("app/models/#{name}.rb") do |content|
        expect(content).to match(/Notification/)
      end
    end
  end

  context 'when the table already exists' do
    let(:table_exists) { true }

    before do
      FileUtils.mkdir_p(File.join(destination_root, 'app/models'))
      content = %(
        class Notification < ApplicationRecord
        end
      )
      File.write(File.join(destination_root, "app/models/#{name}.rb"), content)
      allow($stdin).to receive(:gets).and_return('Y')
      run_generator([name])
    end

    it_behaves_like 'a template generator'

    it 'create the migration file to update the right content' do
      assert_migration("db/migrate/update_#{name.pluralize}.rb") do |migration|
        expect(migration).to match(/add_column/)
      end
    end

    it 'creates the model file' do
      assert_file("app/models/#{name}.rb") do |content|
        expect(content).to match(/include Sincerely::Mixins::Model/)
      end
    end
  end
end
