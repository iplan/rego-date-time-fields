require 'spec_helper'

describe DateTimeFields::ActiveRecord::TypeCaster do
  let(:article){ FactoryGirl.create(:article, :published_at => DateTime.strptime('22/12/2011 13:57', '%d/%m/%Y %H:%M')) }

  describe 'when type casting' do
    let(:type_caster){ DateTimeFields::ActiveRecord::TypeCaster }

    describe 'to_date' do
      let(:format){ '%d/%m/%Y' }
      let(:date_string){ '05/12/2011' }

      it 'should cast to nil a nil object' do
        type_caster.to_date(nil, format).should be_nil
      end

      it 'should cast to nil a String that is not parsable to date' do
        type_caster.to_date('puki', format).should be_nil
        type_caster.to_date('', format).should be_nil
        type_caster.to_date('05-12-2011', format).should be_nil
      end

      it 'should cast to Date a String that parsable to Date according to format' do
        casted = type_caster.to_date(date_string, format)
        casted.should be_a(Date)
        casted.day.should == 5
        casted.month.should == 12
        casted.year.should == 2011
      end

      it 'should cast to date a Date object' do
        date = Date.strptime(date_string, format)
        casted = type_caster.to_date(date, format)
        casted.should == date
      end
    end

    describe 'to_time' do
      let(:format){ '%H:%M' }
      let(:time_string){ '14:57' }

      it 'should cast to nil a nil object' do
        type_caster.to_time(nil, format).should be_nil
      end

      it 'should cast to nil a String that is not parsable to time' do
        type_caster.to_time('puki', format).should be_nil
        type_caster.to_time('', format).should be_nil
        type_caster.to_time('05:84', format).should be_nil
      end

      it 'should cast to time string a string that is parsable accourding to format' do
        casted = type_caster.to_time(time_string, format)
        casted.should be_a(String)
        casted.should == '14:57'
      end

    end

    describe 'date_and_time_to_timestamp' do
      let(:date){ Date.strptime('05/12/2011', '%d/%m/%Y') }
      let(:time_string){ '14:57' }

      it 'should raise ArgumentError if date portion is not a Date' do
        lambda{ type_caster.date_and_time_to_timestamp('df', time_string) }.should raise_error(ArgumentError)
      end

      it 'should raise ArgumentError if time portion is not a String' do
        lambda{ type_caster.date_and_time_to_timestamp(date, 43) }.should raise_error(ArgumentError)
      end

      it 'should cast to nil if either date or time is nil' do
        type_caster.date_and_time_to_timestamp(nil, time_string).should be_nil
        type_caster.date_and_time_to_timestamp(date, nil).should be_nil
      end

      it 'should change existing time to new time' do
        casted = type_caster.date_and_time_to_timestamp(date, time_string)
        casted.should be_a(Time)
        casted.strftime('%d/%m/%Y %H:%M').should == '05/12/2011 14:57'
      end

    end
  end

end
