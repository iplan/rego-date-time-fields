module DateTimeFields
  module ActiveRecord
    extend ActiveSupport::Concern

    module ClassMethods
      def date_attr_writer(*attributes)
        attributes.each do |attr|
          self.class_eval %{
            def #{attr}=(value)
              if !value.nil? && value.is_a?(String)
                @raw_#{attr} = value
                begin
                  value = Date.strptime(value, I18n.t('date.formats.default'))
                rescue Exception
                  value = nil
                end
              end
              self[:#{attr}]=value
            end

            def #{attr}_before_type_cast
              @raw_#{attr}
            end
          }
        end
      end

      def timestamp_attr_writer(*attributes)
        raise ArgumentError.new("At least one attribute must be passed") if attributes.empty?
        options = attributes.last.is_a?(Hash) ? attributes.pop : {}
        options = {:date_format => I18n.t('date.formats.default'), :time_format => '%H:%M'}.update(options)
        attributes.each do |attr|
          attr_date = "#{attr}_date"
          attr_time = "#{attr}_time"
          self.class_eval %{
            def #{attr_date}
              if self.#{attr}.nil?
                @#{attr_date}
              else
                self.#{attr}.to_date
              end
            end

            def #{attr_time}
              if self.#{attr}.nil?
                @#{attr_time}
              else
                self.#{attr}.strftime('#{options[:time_format]}')
              end
            end

            def #{attr_date}=(new_value)
              if new_value.is_a?(String)
                @raw_#{attr_date} = new_value
                begin
                  new_value = Date.strptime(new_value, '#{options[:date_format]}')
                rescue Exception
                  new_value = nil
                end
              elsif new_value.present? && !new_value.is_a?(Date)
                raise ArgumentError.new("Value can be Date object or String object (formatted as #{options[:date_format]}) only. Was: \#{new_value.class.inspect}")
              end

              @#{attr_date} = new_value

              if new_value.present?
                if self.#{attr}.nil?
                  new_value = nil # since we do not want the hour to be 00:00
                else
                  new_value = self.#{attr}.change(:day => new_value.day, :month => new_value.month, :year => new_value.year)
                end
              end
              self.#{attr} = new_value
            end

            def #{attr_time}=(new_value)
              if new_value.is_a?(String)
                @raw_#{attr_time} = new_value
                begin
                  new_value = DateTime.strptime(new_value, '#{options[:time_format]}')
                rescue Exception
                  new_value = nil
                end
              elsif new_value.present?
                raise ArgumentError.new("Value can be String formatted as #{options[:time_format]} only. Was: \#{new_value.class.inspect}")
              end

              @#{attr_time} = new_value.present? ? new_value.strftime('#{options[:time_format]}') : nil

              if new_value.present?
                if self.#{attr}.nil?
                  new_value = nil # since we do not want the date to be today
                else
                  new_value = self.#{attr}.change(:hour => new_value.hour, :min => new_value.min, :sec => new_value.sec)
                end
              end
              self.#{attr} = new_value
            end

            def #{attr}_before_type_cast
              @raw_#{attr}
            end

            def #{attr_date}_before_type_cast
              @raw_#{attr_date}
            end

            def #{attr_time}_before_type_cast
              @raw_#{attr_time}
            end

          }
        end
      end
    end

  end
end

ActiveRecord::Base.send :include, DateTimeFields::ActiveRecord