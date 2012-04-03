module DateTimeFields
  module ActiveRecord
    class TypeCaster

      def self.to_date(value, date_format)
        result = nil
        if value.is_a?(String)
          begin
            result = Date.strptime(value, date_format)
          rescue Exception
          end
        elsif value.is_a?(Date)
          result = value
        end
        result
      end

      def self.to_time(value, time_format)
        result = nil
        if value.is_a?(String)
          begin
            result = DateTime.strptime(value, time_format) # check that can be parsed according to format
            result = result.strftime(time_format) # revert back to string
          rescue Exception
          end
        end
        result
      end

      def self.date_and_time_to_timestamp(new_date, new_time, time_format = '%H:%M')
        result = nil
        if(new_date.present? && new_time.present?)
          raise ArgumentError.new("Date portion must be a date object, was: #{new_date.class}") unless new_date.is_a?(Date)
          raise ArgumentError.new("Date portion must be a string object formatted as date, was: #{new_time.class}") unless new_time.is_a?(String)
          
          time = DateTime.strptime(new_time, time_format)
          result = Time.local(new_date.year, new_date.month, new_date.day, time.hour, time.min, time.sec)
        end
        result
      end
    end
  end
end
