module DateTimeFields

  class RubyToJqueryDateFormatConvertor
    @@replace_hash = {
      '%d' => 'dd',
      '%m' => 'mm',
      '%y' => 'y',
      '%Y' => 'yy',
      '%j' => 'oo',
      '%a' => 'D',
      '%A' => 'DD',
      '%b' => 'M',
      '%B' => 'MM'
    }

    def self.convert(strftime_format)
      strftime_format.gsub(/(%[abdjmyABY])/) do |match|
        new_val = @@replace_hash[match]
        raise ArgumentError.new("Replacing of #{match} is not supported") if new_val.nil?
        new_val
      end
    end

  end
end