module DateTimeFields
  class Railtie < Rails::Railtie
    initializer "gems.date_time_fields" do
      ::ActiveRecord::Base.send :extend, DateTimeFields::ActiveRecord::ClassMethods
      ::ActionView::Base.send :include, DateTimeFields::ActionView::FormOptionsHelper
      ::ActionView::Base.send :include, DateTimeFields::ActionView::FormTagHelper
      ::ActionView::Helpers::FormBuilder.send :include, DateTimeFields::ActionView::FormBuilder
      ::ActionView::Helpers::InstanceTag.send :include, DateTimeFields::ActionView::InstanceTag

      ::ActiveModel::Validations.send :include, DateTimeFields::ActiveModel::Validations
      ::ActiveRecord::Base.send :include, DateTimeFields::ActiveModel::Validations
    end
  end
end
