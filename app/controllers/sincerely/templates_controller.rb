# frozen_string_literal: true

module Sincerely
  class TemplatesController < ApplicationController
    before_action :set_template, only: %i[show edit update preview]

    def index
      @pagination = paginate(Sincerely::Templates::NotificationTemplate.order(created_at: :desc))
      @templates = @pagination[:records]
    end

    def show
      @notification_count = notification_model.where(template_id: @template.id).count
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
      sample_data = params[:sample_data].present? ? JSON.parse(params[:sample_data]) : {}
      @rendered_subject = @template.renderer.render(@template.subject || '', { 'template_data' => sample_data })
      @rendered_html = @template.render(:html, { 'template_data' => sample_data })
      @rendered_text = @template.render(:text, { 'template_data' => sample_data })

      render layout: false
    rescue JSON::ParserError
      render plain: 'Invalid JSON in sample data', status: :bad_request
    end

    private

    def set_template
      @template = Sincerely::Templates::NotificationTemplate.find(params[:id])
    end

    def template_params
      params.require(:template).permit(:name, :subject, :sender, :html_content, :text_content)
    end
  end
end
