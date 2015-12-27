%w(active_record  type_caster  validations  action_view).each do |file_name|
  require "rego-date-time-fields/#{file_name}"
end

require 'rego-date-time-fields/railtie' if defined?(Rails)
