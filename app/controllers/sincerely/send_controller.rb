# frozen_string_literal: true

module Sincerely
  class SendController < ApplicationController
    MAX_RECIPIENTS = 50
    EMAIL_PATTERN = /\A[^@\s]+@[^@\s]+\z/
    RECIPIENT_DELIMITER = /[\s,;\n]+/

    private_constant :MAX_RECIPIENTS, :EMAIL_PATTERN, :RECIPIENT_DELIMITER

    def new
      @templates = available_templates
    end

    def create
      return render_error('No valid recipients provided') if recipients.empty?
      return render_error("Maximum #{MAX_RECIPIENTS} recipients allowed") if recipients.size > MAX_RECIPIENTS
      return render_error('Template not found') unless template

      render json: send_results
    end

    def template_variables
      return render json: { variables: [] } unless template

      render json: { variables: extract_liquid_variables.uniq.sort }
    end

    private

    def available_templates
      Sincerely::Templates::NotificationTemplate.order(:name)
    end

    def template
      @template ||= Sincerely::Templates::NotificationTemplate.find_by(id: params[:template_id] || params[:id])
    end

    def recipients
      @recipients ||= parse_recipients(params[:recipients])
    end

    def template_data
      @template_data ||= params[:template_data]&.to_unsafe_h || {}
    end

    def send_results
      results = { sent: 0, failed: 0, errors: [] }

      recipients.each { |recipient| process_recipient(recipient, results) }

      { success: true, sent: results[:sent], failed: results[:failed], errors: results[:errors].first(5) }
    end

    def process_recipient(recipient, results)
      notification = build_notification(recipient)

      if notification.save
        deliver_notification(notification, recipient, results)
      else
        record_failure(results, recipient, notification.errors.full_messages.join(', '))
      end
    end

    def build_notification(recipient)
      notification_model.new(
        recipient:,
        notification_type: 'email',
        template_id: template.id,
        delivery_options: { template_data: }
      )
    end

    def deliver_notification(notification, recipient, results)
      notification.deliver
      results[:sent] += 1
    rescue StandardError => e
      record_failure(results, recipient, e.message)
    end

    def record_failure(results, recipient, error)
      results[:failed] += 1
      results[:errors] << { recipient:, error: }
    end

    def render_error(message)
      render json: { success: false, error: message }, status: :unprocessable_entity
    end

    def parse_recipients(input)
      return [] if input.blank?

      input.split(RECIPIENT_DELIMITER)
           .map(&:strip)
           .compact_blank
           .grep(EMAIL_PATTERN)
           .uniq
    end

    def extract_liquid_variables
      template_content.scan(/\{\{\s*([a-zA-Z_][a-zA-Z0-9_]*(?:\.[a-zA-Z_][a-zA-Z0-9_]*)*)\s*\}\}/)
                      .flatten
                      .map { |v| v.split('.').first }
    end

    def template_content
      [template.subject, template.html_content, template.text_content].compact.join(' ')
    end
  end
end
