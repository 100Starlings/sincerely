# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'TemplateModel' do
  describe 'validations' do
    subject(:model) { NotificationTemplate.new(**attributes) }

    context 'with proper attributes' do
      let(:attributes) { { name: 'template' } }

      it 'is valid' do
        expect(model.valid?).to be true
      end
    end

    context 'with missing name' do
      let(:attributes) { {} }

      it 'is invalid' do
        expect(model.valid?).to be false
      end

      it 'shows error message' do
        model.valid?
        expect(model.errors.full_messages).to include("Name can't be blank")
      end
    end
  end
end
