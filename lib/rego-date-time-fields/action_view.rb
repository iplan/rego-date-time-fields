module DateTimeFields
  module ActionView

    module FormOptionsHelper
      def date_field(object_name, method, options = {}, html_options = {})
        value = I18n.l(options[:object].send(method).to_date) unless options[:object].send(method).empty?
        options = {:format => t('date.formats.jQuery.default')}.merge(options)
        html_options = {
                :value=>value,
                :style=>"#{options[:static] ? 'display:none' : ''}",
                :id=>"#{object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{method.to_s.sub(/\?$/,"")}"
        }.update(html_options)

        # MUST use instance tag, so error message would be displayed near date field
        input_field_tag = ::ActionView::Helpers::InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag("text", html_options)
        capture_haml do
          #haml_concat text_field object_name, method, html_options
          haml_concat input_field_tag
          haml_concat javascript_tag "
            jQuery('##{html_options[:id]}').datepicker(jQuery.extend({}, jQuery.datepicker.regional['#{I18n.locale}'], { dateFormat: '#{options[:format]}' }));
          "
        end
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
      def timestamp_field(method, options = {}, html_options = {})
        timestamp_date_field(method, options, html_options) + timestamp_time_field(method, options, html_options)
      end

      def timestamp_date_field(method, options = {}, html_options = {})
        options = {}.merge(options)
        method = method.to_s
        html_options = {:name=>"#{@object_name}[#{method}_date]"}.merge(html_options)
        @template.date_field(@object_name, "#{method}_date", objectify_options(options), @default_options.merge(html_options))
      end

      def timestamp_time_field(method, options = {}, html_options = {})
        options = {:start_hour => 9}.merge(options)
        method = method.to_s
        html_options = {:name=>"#{@object_name}[#{method}_time]"}.merge(html_options)

        start_hour = options.delete(:start_hour)
        hours = (start_hour...(start_hour+24)).to_a.collect{|n| (n%24).to_s.rjust(2,'0')}
        minutes = (0..59).step(15).to_a.collect{|n| n.to_s.rjust(2,'0')}
        time_arr = hours.collect{|h| minutes.collect{|m| "#{h}:#{m}"}}.flatten

        unless @object.send(method).nil?
          hour = @object.send(method).hour.to_s.rjust(2,'0')
          minute = @object.send(method).min.to_s.rjust(2,'0')
          selected = "#{hour}:#{minute}"
        end

        choices = @template.options_for_select(time_arr, @object.send(method+'_time'))
        select("#{method}_time", choices, options, @default_options.merge(html_options))
      end

      def date_field(method, options = {}, html_options = {})
        options = {}.merge(options)
        @template.date_field(@object_name, method, objectify_options(options), @default_options.merge(html_options))
      end

      def date_time_field(method, options = {}, html_options = {})
        options = {}.merge(options)
        @template.date_time_field(@object_name, method, objectify_options(options), @default_options.merge(html_options))
      end

    end


  end
end


require 'action_view'
ActionView::Base.send :include, DateTimeFields::ActionView::FormOptionsHelper
ActionView::Helpers::FormBuilder.send :include, DateTimeFields::ActionView::FormBuilder