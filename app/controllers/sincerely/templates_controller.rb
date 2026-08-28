# frozen_string_literal: true

module Sincerely
  class TemplatesController < ApplicationController
    include Concerns::Pagination

    before_action :set_template, only: %i[show edit update preview]

    def index
      @pagination = paginate(all_templates)
      @templates = @pagination[:records]
    end

    def show
      @notification_count = template_notification_count
    end

    def new
      @template = Sincerely::Templates::EmailLiquidTemplate.new
    end

    def edit; end

    def create
      @template = Sincerely::Templates::EmailLiquidTemplate.new(template_params)

      if @template.save
        redirect_to template_path(@template), notice: 'Template created successfully'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @template.update(template_params)
        redirect_to template_path(@template), notice: 'Template updated successfully'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def preview
      render_preview
    rescue JSON::ParserError
      render plain: 'Invalid JSON in sample data', status: :bad_request
    rescue ArgumentError => e
      render plain: e.message, status: :bad_request
    rescue Liquid::Error => e
      render plain: "Template rendering error: #{e.message}", status: :unprocessable_entity
    end

    private

    def set_template
      @template = Sincerely::Templates::NotificationTemplate.find(params[:id])
    end

    def template_params
      params.require(:template).permit(:name, :subject, :sender, :html_content, :text_content)
    end

    def all_templates
      Sincerely::Templates::NotificationTemplate.order(created_at: :desc)
    end

    def template_notification_count
      notification_model.where(template_id: @template.id).count
    end

    def render_preview
      @rendered_subject = @template.renderer.render(@template.subject || '', preview_context)
      @rendered_html = @template.render(:html, preview_context)
      @rendered_text = @template.render(:text, preview_context)
      render layout: false
    end

    def preview_context
      { 'template_data' => parsed_sample_data }
    end

    def parsed_sample_data
      return {} if params[:sample_data].blank?

      parsed = JSON.parse(params[:sample_data])
      raise ArgumentError, 'Sample data must be a JSON object' unless parsed.is_a?(Hash)

      parsed
    end
  end
end
