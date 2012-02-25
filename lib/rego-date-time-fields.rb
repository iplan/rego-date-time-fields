#puts "load #{__FILE__}"

%w{active_record  type_caster  action_view  ruby_to_jquery_date_format_convertor}.each do |file_name|
  require File.join(File.dirname(__FILE__), 'rego-date-time-fields', file_name)
end

module DateTimeFields

end
