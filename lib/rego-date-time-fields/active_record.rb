module DateTimeFields
  module ActiveRecord
    extend ActiveSupport::Concern

    module ClassMethods
      def date_attr_writer(*attributes)
        raise ArgumentError.new("At least one attribute must be passed") if attributes.empty?
        options = attributes.last.is_a?(Hash) ? attributes.pop : {}
        options = {:date_format => I18n.t('date.formats.default')}.update(options)
        attributes.each do |attr|
          self.class_eval %{
            def #{attr}=(new_value)
              @raw_#{attr} = new_value
              self[:#{attr}] = TypeCaster.to_date(new_value, '#{options[:date_format]}')
            end

            def #{attr}_before_type_cast
              @raw_#{attr} || self[:#{attr}]
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
              @raw_#{attr_date} = new_value
              @#{attr_date} = TypeCaster.to_date(new_value, '#{options[:date_format]}')

              casted_time = TypeCaster.to_time(#{attr_time}_before_type_cast, '#{options[:time_format]}')
              self.#{attr} = TypeCaster.date_and_time_to_timestamp(@#{attr_date}, casted_time, '#{options[:time_format]}')
            end

            def #{attr_time}=(new_value)
              @raw_#{attr_time} = new_value
              @#{attr_time} = TypeCaster.to_time(new_value, '#{options[:time_format]}')

              casted_date = TypeCaster.to_date(#{attr_date}_before_type_cast, '#{options[:date_format]}')
              self.#{attr} = TypeCaster.date_and_time_to_timestamp(casted_date, @#{attr_time}, '#{options[:time_format]}')
            end

            def #{attr_date}_before_type_cast
              @raw_#{attr_date} || #{attr_date}
            end

            def #{attr_time}_before_type_cast
              @raw_#{attr_time} || #{attr_time}
            end

          }
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, DateTimeFields::ActiveRecord