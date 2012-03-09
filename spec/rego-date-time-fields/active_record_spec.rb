require 'spec_helper'

describe ActiveRecord::Base do
  let(:article){ FactoryGirl.create(:article, :published_at => DateTime.strptime('22/12/2011 13:57', '%d/%m/%Y %H:%M')) }

  it 'should have getters and setters and before_type_casts defined' do
    article.should respond_to(:published_at)
    article.should respond_to(:published_at_date)
    article.should respond_to(:published_at_date_before_type_cast)
    article.should respond_to(:published_at_date=)
    article.should respond_to(:published_at_time)
    article.should respond_to(:published_at_time_before_type_cast)
    article.should respond_to(:published_at_time=)
  end

  describe 'simple getters' do
    it 'should return nil if timestamp attribute is nil' do
      article.update_attribute(:published_at, nil)
      article.reload

      article.published_at.should be_nil
      article.published_at_date.should be_nil

      article.published_at.should be_nil
      article.published_at_time.should be_nil
    end

    it 'should return date portion of timestamp' do
      article.published_at.should be_present

      article.published_at_date.should be_a(Date)
      article.published_at_date.day.should == 22
      article.published_at_date.month.should == 12
      article.published_at_date.year.should == 2011

      article.published_at_time.should be_a(String)
      article.published_at_time.should == '13:57'
    end

    it 'should have before_type_cast equal to date attribute until setter is invoked' do
      article.published_at_date_before_type_cast.should be_a(Date)
      article.published_at_time_before_type_cast.should be_a(String)
      article.published_at_date_before_type_cast.strftime('%d/%m/%Y').should == '22/12/2011'
      article.published_at_time_before_type_cast.should == '13:57'

      article.update_attribute(:published_at, nil)
      article.reload

      article.published_at_date_before_type_cast.should be_nil
      article.published_at_time_before_type_cast.should be_nil
    end
  end

  describe 'when setting date attribute value' do

    it 'should change only date portion of timestamp attribute when Date object is passed' do
      date = Date.strptime('28/11/2011', '%d/%m/%Y')
      article.published_at_date = date
      article.published_at_date.should == date
      article.published_at_date_before_type_cast.should == date
      article.published_at_date.strftime('%d/%m/%Y').should == '28/11/2011'

      article.published_at.should be_present
      article.published_at.strftime('%d/%m/%Y %H:%M').should == '28/11/2011 13:57'
    end

    it 'should change only date portion of timestamp attribute when String object is typecasted to Date object' do
      article.published_at_date = '28/11/2011'
      article.published_at_date.should be_a(Date)
      article.published_at_date_before_type_cast.should == '28/11/2011'
      article.published_at_date.strftime('%d/%m/%Y').should == '28/11/2011'

      article.published_at.should be_present
      article.published_at.strftime('%d/%m/%Y %H:%M').should == '28/11/2011 13:57'
    end

    it 'should nullify timestamp attribute when nil is passed' do
      article.published_at_date = nil
      article.published_at_date.should be_nil
      article.published_at_date_before_type_cast.should be_nil
      article.published_at.should be_nil

      article.published_at_time.should be_nil
    end

    it 'should nullify timestamp attribute when cannot typecast to Date' do
      article.published_at_date = 'puki'
      article.published_at_date.should be_nil
      article.published_at_date_before_type_cast.should == 'puki'
      article.published_at.should be_nil

      article.published_at_time.should be_nil
    end

    it 'should leave previous time attribute when invalid date was passed' do
      article.published_at_time = '13:44'
      article.published_at_time.should == '13:44'

      article.published_at_date = 'kuku'
      article.published_at_date.should be_nil

      article.published_at_time.should == '13:44'
      article.published_at_time_before_type_cast.should == '13:44'
    end
  end

end
