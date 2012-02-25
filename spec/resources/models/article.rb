class Article < ActiveRecord::Base

  timestamp_attr_writer :published_at, :date_format => '%d/%m/%Y'

end