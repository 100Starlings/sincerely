# frozen_string_literal: true

module Sincerely
  module ChartHelper
    STATE_COLORS = {
      'draft' => '#9ca3af',
      'accepted' => '#B9E0B8',
      'delivered' => '#10b981',
      'opened' => '#78c6cc',
      'clicked' => '#BDD9DB',
      'bounced' => '#D4183D',
      'rejected' => '#D4183D',
      'complained' => '#D4183D',
      'delayed' => '#f97316'
    }.freeze

    DEFAULT_COLOR = '#6b7280'

    LINE_CHART = {
      width: 800, height: 220,
      padding_left: 45, padding_right: 20,
      padding_top: 20, padding_bottom: 30
    }.freeze

    DONUT_RADIUS = 68

    def state_color(state)
      STATE_COLORS[state.to_s] || DEFAULT_COLOR
    end

    def line_chart_config(series, labels)
      plot_width  = LINE_CHART[:width]  - LINE_CHART[:padding_left] - LINE_CHART[:padding_right]
      plot_height = LINE_CHART[:height] - LINE_CHART[:padding_top]  - LINE_CHART[:padding_bottom]

      max_value = [series.values.flatten.max || 0, 1].max
      magnitude = 10**Math.log10(max_value).floor
      max_y     = [((max_value.to_f / magnitude).ceil * magnitude).to_i, 1].max
      x_step    = labels.length > 1 ? plot_width.to_f / (labels.length - 1) : plot_width

      LINE_CHART.merge(plot_width:, plot_height:, max_y:, x_step:)
    end

    def line_chart_points(values, config)
      values.each_with_index.map do |value, i|
        x = config[:padding_left] + (i * config[:x_step])
        y = config[:padding_top] + config[:plot_height] - (value.to_f / config[:max_y] * config[:plot_height])
        "#{x.round(2)},#{y.round(2)}"
      end.join(' ')
    end

    def line_chart_area_points(points_str, values, config)
      bottom_y = config[:padding_top] + config[:plot_height]
      last_x   = config[:padding_left] + ((values.length - 1) * config[:x_step])
      "#{config[:padding_left]},#{bottom_y} #{points_str} #{last_x},#{bottom_y}"
    end

    def donut_segment_data(notifications_by_state)
      total         = notifications_by_state.values.sum
      circumference = 2 * Math::PI * DONUT_RADIUS
      offset        = 0

      notifications_by_state.map do |state, count|
        dash_length = circumference * (count.to_f / total)
        visible_dash = [dash_length + 0.5, circumference].min
        segment = {
          state:, count:,
          color: state_color(state),
          visible_dash:,
          gap: [circumference - visible_dash, 0].max,
          offset: -offset
        }
        offset += dash_length
        segment
      end
    end
  end
end
