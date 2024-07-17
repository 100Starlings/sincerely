# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sincerely::Templates::EmailLiquidTemplate do
  describe 'validations' do
    subject(:model) { described_class.new(**attributes) }

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

  describe '#render' do
    subject(:render) { model.render(content_type, options) }

    let(:options) { { template_data: { name: 'John Doe' } } }
    let(:model) do
      described_class.create(name: 'template', html_content:, text_content:)
    end
    let(:html_content) do
      <<~HTML
        <ul id="products">
          <li>
            <h2>{{ name }}</h2>
          </li>
        </ul>
      HTML
    end
    let(:text_content) { 'hi {{name}}' }

    context 'when rendering html content' do
      let(:content_type) { :html }

      it 'returns rendered html content' do # rubocop:disable RSpec/ExampleLength
        html_content =
          <<~HTML
            <ul id="products">
              <li>
                <h2>John Doe</h2>
              </li>
            </ul>
          HTML
        expect(render).to eq(html_content)
      end
    end

    context 'when rendering text content' do
      let(:content_type) { :text }

      it 'returns rendered text content' do
        expect(render).to eq('hi John Doe')
      end
    end
  end
end
