module DateTimeFields
  module ActionView

    module FormTagHelper
      def date_field_tag(name, value = nil, options = {}, html_options = {})
        options = {
          :format => I18n.t('date.formats.default'),
          :show_other_months => true,
          :select_other_months => true,
          :static => false
        }.merge(options)

        value = I18n.l(value.to_date, :format => options[:format]) if value.present? && (value.is_a?(Date) || value.is_a?(Time))

        html_options = { :type => "text", :name => name, :id => sanitize_to_id(name), :value => value }.update(html_options.stringify_keys)

        input_field_tag = tag :input, html_options
        js_tag = javascript_tag DateTimeFields::ActionView::JqueryDatePicker.date_picker_js(options.update(:id => html_options[:id]))
        #js_tag = javascript_tag "
        #    jQuery('##{html_options[:id]}').datepicker(jQuery.extend({}, jQuery.datepicker.regional['#{I18n.locale}'], {
        #      dateFormat: '#{DateTimeFields::TypeCaster.ruby_date_format_to_jquery_date_format(options[:format])}',
        #      showOtherMonths: #{options[:show_other_months]},
        #      selectOtherMonths: #{options[:select_other_months]}
        #    }));
        #"
        input_field_tag << js_tag
      end
    end

    module FormOptionsHelper
      def date_field(object_name, method, options = {}, html_options = {})
        options = {
          :format => I18n.t('date.formats.default'),
          :show_other_months => true,
          :select_other_months => true,
          :static => false
        }.merge(options)
        value = I18n.l(options[:object].send(method).to_date, :format => options[:format]) unless options[:object].send(method).blank?
        html_options = {
                :value=>value,
                :style=>"#{options[:static] ? 'display:none' : ''}",
                :id=>"#{object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{method.to_s.sub(/\?$/,"")}"
        }.update(html_options)

        # MUST use instance tag, so error message would be displayed near date field
        input_field_tag = ::ActionView::Helpers::InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag("text", html_options)
        js_tag = javascript_tag DateTimeFields::ActionView::JqueryDatePicker.date_picker_js(options.update(:id => html_options[:id]))
        #js_tag = javascript_tag "
        #    jQuery('##{html_options[:id]}').datepicker(jQuery.extend({}, jQuery.datepicker.regional['#{I18n.locale}'], {
        #      dateFormat: '#{DateTimeFields::TypeCaster.ruby_date_format_to_jquery_date_format(options[:format])}',
        #      showOtherMonths: #{options[:show_other_months]},
        #      selectOtherMonths: #{options[:select_other_months]}
        #    }));
        #"
        input_field_tag << js_tag
      end

      def date_time_field(object, method, options = {}, html_options = {})
        options = {
          :date_format => I18n.t('date.formats.default'), :time_format => t('time.formats.jQuery.default'), :step_minute => 0.5, :hour_min => 0, :hour_max => 23, :minute_grid => 0
        }.merge(options)
        value = I18n.l(options[:object].send(method), :format => options[:date_format]) unless options[:object].send(method).empty?
        html_options = {
                :value=>value,
                :style=>"#{options[:static] ? 'display:none' : ''}",
                :id=>"#{object.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}_#{method.to_s.sub(/\?$/,"")}"
        }.update(html_options)
        capture_haml do
          haml_concat text_field object, method, html_options
          haml_concat javascript_tag(DateTimeFields::ActionView::JqueryDatePicker.date_time_picker_js(options.update(:id => html_options[:id])))
          #haml_concat javascript_tag "
          #  jQuery('##{html_options[:id]}').datetimepicker(jQuery.extend({}, jQuery.datepicker.regional['#{I18n.locale}'], {
          #    dateFormat: '#{DateTimeFields::TypeCaster.ruby_date_format_to_jquery_date_format(options[:date_format])}',
          #    showOtherMonths: #{options[:show_other_months]},
          #    timeFormat: '#{options[:time_format]}',
          #    stepMinute: #{options[:step_minute]},
          #    hourMin: #{options[:hour_min]},
          #    hourMax: #{options[:hour_max]},
          #    minuteGrid: #{options[:minute_grid]}
          #  }))
          #"
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
        selected_value = object.send(method)
        selected_value_hour, selected_value_minute = selected_value.split(':') if selected_value.present?
        time_arr = hours.collect do |h|
          if selected_value_hour.present? && h==selected_value_hour
            minutes = (minutes + [selected_value_minute]).uniq.sort_by{|m|m.to_i} #add selected minute to minutes array if it does not include it
          end
          minutes.collect{|m| "#{h}:#{m}"}
        end
        time_arr = time_arr.flatten
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

    module JqueryDatePicker

      def self.date_picker_js(options)
        "
          jQuery('##{options[:id]}').datepicker(jQuery.extend({}, jQuery.datepicker.regional['#{I18n.locale}'], {
            dateFormat: '#{DateTimeFields::TypeCaster.ruby_date_format_to_jquery_date_format(options[:format])}',
            showOtherMonths: #{options[:show_other_months]},
            selectOtherMonths: #{options[:select_other_months]}
          }));
        "
      end

      def self.date_time_picker_js(options)
        "
          jQuery('##{options[:id]}').datetimepicker(jQuery.extend({}, jQuery.datepicker.regional['#{I18n.locale}'], {
            dateFormat: '#{DateTimeFields::TypeCaster.ruby_date_format_to_jquery_date_format(options[:date_format])}',
            showOtherMonths: #{options[:show_other_months]},
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
end
