# frozen_string_literal: true

module Sincerely
  class SendController < ApplicationController
    MAX_RECIPIENTS = 50

    def new
      @templates = Sincerely::Templates::NotificationTemplate.order(:name)
    end

    def create
      recipients = parse_recipients(params[:recipients])

      if recipients.empty?
        render json: { success: false, error: 'No valid recipients provided' }, status: :unprocessable_entity
        return
      end

      if recipients.size > MAX_RECIPIENTS
        render json: { success: false, error: "Maximum #{MAX_RECIPIENTS} recipients allowed" },
               status: :unprocessable_entity
        return
      end

      template = Sincerely::Templates::NotificationTemplate.find_by(id: params[:template_id])
      unless template
        render json: { success: false, error: 'Template not found' }, status: :unprocessable_entity
        return
      end

      template_data = params[:template_data]&.to_unsafe_h || {}

      results = { sent: 0, failed: 0, errors: [] }

      recipients.each do |recipient|
        notification = notification_model.new(
          recipient: recipient,
          notification_type: 'email',
          template_id: template.id,
          delivery_options: { 'template_data' => template_data }
        )

        if notification.save
          begin
            notification.deliver
            results[:sent] += 1
          rescue StandardError => e
            results[:failed] += 1
            results[:errors] << { recipient: recipient, error: e.message }
          end
        else
          results[:failed] += 1
          results[:errors] << { recipient: recipient, error: notification.errors.full_messages.join(', ') }
        end
      end

      render json: {
        success: true,
        sent: results[:sent],
        failed: results[:failed],
        errors: results[:errors].first(5) # Limit error details
      }
    end

    def template_variables
      template = Sincerely::Templates::NotificationTemplate.find_by(id: params[:id])

      unless template
        render json: { variables: [] }
        return
      end

      variables = extract_liquid_variables(template)
      render json: { variables: variables.uniq.sort }
    end

    private

    def parse_recipients(input)
      return [] if input.blank?

      # Split by comma, semicolon, space, or newline
      input.split(/[\s,;\n]+/)
           .map(&:strip)
           .reject(&:blank?)
           .select { |email| email.match?(/\A[^@\s]+@[^@\s]+\z/) }
           .uniq
           .first(MAX_RECIPIENTS)
    end

    def extract_liquid_variables(template)
      content = [
        template.subject,
        template.html_content,
        template.text_content
      ].compact.join(' ')

      # Extract {{ variable }} and {{ variable.property }} patterns
      content.scan(/\{\{\s*([a-zA-Z_][a-zA-Z0-9_]*(?:\.[a-zA-Z_][a-zA-Z0-9_]*)*)\s*\}\}/)
             .flatten
             .map { |v| v.split('.').first } # Get root variable name
             .uniq
    end
  end
end
