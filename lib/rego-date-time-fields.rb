#puts "load #{__FILE__}"

%w{active_record  action_view}.each do |file_name|
  require File.join(File.dirname(__FILE__), 'rego-date-time-fields', file_name)
end

module DateTimeFields

end
