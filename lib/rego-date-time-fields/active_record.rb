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
                self.#{attr}.strftime('%H:%M')
              end
            end

            def #{attr_date}=(new_value)
              if new_value.present? && new_value.is_a?(String)
                @raw_#{attr_date} = new_value
                begin
                  new_value = Date.strptime(value, I18n.t('date.formats.default'))
                rescue Exception
                  new_value = nil
                end
              elsif new_value.present? && !new_value.is_a?(Date)
                raise ArgumentError.new("Value can be String or Date object only, was: \#{new_value.class.inspect}") if
              end

              @#{attr_date} = new_value

              if new_value.present?
                if self.#{attr}.nil?
                  new_value = new_value.to_time
                else
                  new_value = self.#{attr}.change(:day => new_value.day, :month => new_value.month, :year => new_value.year)
                end
              end
              self.#{attr} = new_value
            end

            def #{attr_time}=(new_value)
              if self.#{attr}.nil?
                @#{attr_time} = new_value
              else
                self.#{attr} = self.#{attr}.change(:hour => new_value.split(':').first, :min => new_value.split(':').last)
              end
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

            def #{attr}=(value)
              if !value.nil?
                @raw_#{attr} = value
                begin
                  #if value.is_a?(String)
                  #  value = Time.at(value[0,10].to_i)
                  #els
                  if value.is_a?(Hash)
                    value_date = value['date']
                    value_time = value['time']
                    date = Date.strptime(value_date, I18n.t('date.formats.default'))
                    @raw_#{attr} = value_date + ' ' + value_time
                    value = Time.local(date.year, date.month, date.day, value_time.split(':').first, value_time.split(':').last)
                  else value.kind_of?(Time)
                    value_date = value.to_date
                    value_time = value.strftime('%H:%M')
                  end
                rescue Exception
                  value = nil
                end
              end
              @raw_#{attr_date} = value_date
              @raw_#{attr_time} = value_time
              self[:#{attr}]=value
            end

          }
        end
      end
    end

  end
end

ActiveRecord::Base.send :include, DateTimeFields::ActiveRecord