module DateTimeFields
  module ActionView

    module FormOptionsHelper
      def date_field(object_name, method, options = {}, html_options = {})
        value = I18n.l(options[:object].send(method).to_date) unless options[:object].send(method).blank?
        options = {:format => t('date.formats.jQuery.default')}.merge(options)
        html_options = {
                :value=>value,
                :style=>"#{options[:static] ? 'display:none' : ''}",
                :id=>"#{object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{method.to_s.sub(/\?$/,"")}"
        }.update(html_options)

        # MUST use instance tag, so error message would be displayed near date field
        input_field_tag = ::ActionView::Helpers::InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag("text", html_options)
        js_tag = javascript_tag "
            jQuery('##{html_options[:id]}').datepicker(jQuery.extend({}, jQuery.datepicker.regional['#{I18n.locale}'], { dateFormat: '#{options[:format]}' }));
        "
        input_field_tag << js_tag
      end

      def date_time_field(object, method, options = {}, html_options = {})
        value = I18n.l(options[:object].send(method)) unless options[:object].send(method).empty?
        options = {
          :date_format => t('date.formats.jQuery.default'), :time_format => t('time.formats.jQuery.default'), :step_minute => 0.5, :hour_min => 0, :hour_max => 23, :minute_grid => 0
        }.merge(options)
        html_options = {
                :value=>value,
                :style=>"#{options[:static] ? 'display:none' : ''}",
                :id=>"#{object.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{method.to_s.sub(/\?$/,"")}"
        }.update(html_options)
        capture_haml do
          haml_concat text_field object, method, html_options
          haml_concat javascript_tag "
            jQuery('##{html_options[:id]}').datetimepicker(jQuery.extend({}, jQuery.datepicker.regional['#{I18n.locale}'], {
              dateFormat: '#{options[:date_format]}',
              timeFormat: '#{options[:time_format]}',
              stepMinute: #{options[:step_minute]},
              hourMin: #{options[:hour_min]},
              hourMax: #{options[:hour_max]},
              minuteGrid: #{options[:minute_grid]}
            }))
          "
        end
      end
    end

    module FormBuilder

      def date_field(method, options = {}, html_options = {})
        options = {}.merge(options)
        @template.date_field(@object_name, method, objectify_options(options), @default_options.merge(html_options))
      end

      def time_field(method, options = {}, html_options = {})
        options = {:from_hour => 9, :to_hour => 8, :minutes_step => 15}.merge(options)
        method = method.to_s

        start_hour = options.delete(:from_hour)
        end_hour = options.delete(:to_hour)
        end_hour += 24 if end_hour <= start_hour
        hours = (start_hour..end_hour).to_a.collect{|n| (n%24).to_s.rjust(2,'0')}

        minutes_step = options.delete(:minutes_step)
        minutes = (0..59).step(minutes_step).to_a.collect{|n| n.to_s.rjust(2,'0')}

        last_hour = hours.pop
        time_arr = hours.collect{|h| minutes.collect{|m| "#{h}:#{m}"}}.flatten
        last_time = "#{last_hour}:00"
        time_arr << last_time unless time_arr.first == last_time

        choices = @template.options_for_select(time_arr, @object.send(method))
        select(method, choices, options, @default_options.merge(html_options))
      end

      def date_time_field(method, options = {}, html_options = {})
        options = {}.merge(options)
        @template.date_time_field(@object_name, method, objectify_options(options), @default_options.merge(html_options))
      end

    end

  end
end


require 'action_view'
ActionView::Helpers::FormHelper.send :include, DateTimeFields::ActionView::FormOptionsHelper
ActionView::Helpers::FormBuilder.send :include, DateTimeFields::ActionView::FormBuilder
