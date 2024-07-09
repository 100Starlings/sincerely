# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Model' do
  describe 'validations' do
    subject(:model) { Notification.new(**attributes) }

    context 'with proper attributes' do
      let(:attributes) { { recipient: 'recipient', notification_type: 'email' } }

      it 'is valid' do
        expect(model.valid?).to be true
      end
    end

    context 'with missing receipient' do
      let(:attributes) { {} }

      it 'is invalid' do
        expect(model.valid?).to be false
      end

      it 'shows error message' do
        model.valid?
        expect(model.errors.full_messages).to include("Recipient can't be blank")
      end
    end

    context 'with inproper notification_type' do
      let(:attributes) { { notification_type: 'test' } }

      it 'is invalid' do
        expect(model.valid?).to be false
      end

      it 'shows error message' do
        model.valid?
        expect(model.errors.full_messages).to include('Notification type is not included in the list')
      end
    end
  end
end
