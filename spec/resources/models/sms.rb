class Sms < ActiveRecord::Base

  timestamp_attr_writer :sent_at, :date_format => '%d/%m/%Y'

  validates_presence_of :name, :sent_at_date, :sent_at_time
  validates_numericality_of :cost, :allow_nil => true, :greater_than_or_equal_to => 10

end