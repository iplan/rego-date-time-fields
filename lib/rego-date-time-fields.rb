#puts "load #{__FILE__}"
require 'rego-date-time-fields/active_record'
require 'rego-date-time-fields/type_caster'
require 'rego-date-time-fields/ruby_to_jquery_date_format_convertor'
require 'rego-date-time-fields/action_view'

#%w{active_record  type_caster  action_view  ruby_to_jquery_date_format_convertor}.each do |file_name|
#  require File.join(File.dirname(__FILE__), 'rego-date-time-fields', file_name)
#end

#module DateTimeFields
#
#end

require 'rego-date-time-fields/railtie' if defined?(Rails)
