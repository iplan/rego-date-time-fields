module DateTimeFields
  class Railtie < Rails::Railtie
    initializer "gems.date_time_fields" do
      ::ActiveRecord::Base.send :extend, DateTimeFields::ActiveRecord::ClassMethods
      ::ActionView::Helpers::FormHelper.send :include, DateTimeFields::ActionView::FormOptionsHelper
      ::ActionView::Helpers::FormBuilder.send :include, DateTimeFields::ActionView::FormBuilder
    end
  end
end
