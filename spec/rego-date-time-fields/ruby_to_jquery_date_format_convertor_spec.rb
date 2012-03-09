require 'spec_helper'

describe DateTimeFields::RubyToJqueryDateFormatConvertor do
  let(:convertor){ DateTimeFields::RubyToJqueryDateFormatConvertor }

  it 'should convert date digits' do
    convertor.convert('%d/%m/%y').should == 'dd/mm/y'
    convertor.convert('%d-%m/%Y').should == 'dd-mm/yy'
    convertor.convert('%d-%m/%Y %j').should == 'dd-mm/yy oo'
  end

  it 'should convert words' do
    convertor.convert('%a %b %m-%y').should == 'D M mm-y'
    convertor.convert('%A %B %m-%Y').should == 'DD MM mm-yy'
  end

end
