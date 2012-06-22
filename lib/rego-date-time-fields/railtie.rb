module DateTimeFields
  class Railtie < Rails::Railtie
    initializer "gems.date_time_fields" do
      ::ActiveRecord::Base.send :extend, DateTimeFields::ActiveRecord::ClassMethods
      ::ActionView::Base.send :include, DateTimeFields::ActionView::FormOptionsHelper
      ::ActionView::Base.send :include, DateTimeFields::ActionView::FormTagHelper
      ::ActionView::Helpers::FormBuilder.send :include, DateTimeFields::ActionView::FormBuilder
    end
  end
end
