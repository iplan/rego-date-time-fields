require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiveRecord::Base" do
  let(:article){ FactoryGirl.create(:article, :published_at => DateTime.strptime('22/12/2011 13:57', '%d/%m/%Y %H:%M')) }

  describe '#published_at_date' do
    it 'should have virtual attribute published_at_date' do
      article.should respond_to(:published_at)
      article.should respond_to(:published_at_date)
      article.should respond_to(:published_at_date)
    end

    it 'should return nil if timestamp attribute is nil' do
      article.update_attribute(:published_at, nil)
      article.reload
      article.published_at.should be_nil
      article.published_at_date.should be_nil
    end

    it 'should return date portion of timestamp' do
      article.published_at_date.should be_a(Date)
      article.published_at_date.day.should == 22
      article.published_at_date.month.should == 12
      article.published_at_date.year.should == 2011
    end
  end

  describe '#published_at_date=' do
    it 'should have virtual attribute published_at_date=' do
      article.should respond_to(:published_at)
      article.should respond_to(:published_at_date=)
    end

    it 'should assign nil to timestamp attribute when nil is passed' do
      article.published_at_date = nil
      article.published_at_date.should be_nil
      article.published_at.should be_nil
      article.save.should be_true
      article.reload.published_at.should be_nil
    end

    it 'should change only date portion of timestamp attribute when Date object is passed' do
      article.published_at_date = Date.strptime('28/11/2011', '%d/%m/%Y')
      article.published_at_date.day.should == 28
      article.published_at_date.month.should == 11
      article.published_at_date.year.should == 2011
      article.published_at.should be_present
      article.published_at.strftime('%d/%m/%Y %H:%M').should == '28/11/2011 13:57'
    end

    it 'should parse string value to Date object' do
      article.published_at_date = '28/11/2011'
      article.published_at_date.day.should == 28
      article.published_at_date.month.should == 11
      article.published_at_date.year.should == 2011
      article.published_at.should be_present
      article.published_at.strftime('%d/%m/%Y %H:%M').should == '28/11/2011 13:57'
    end

    it 'should assign nil if string parsing to Date object fails' do
      article.published_at_date = '28-11-2011'
      article.published_at_date.should be_nil
      article.published_at.should be_nil

      article.reload.published_at.should be_present
      article.published_at_date = ''
      article.published_at_date.should be_nil
      article.published_at.should be_nil
    end

    it 'should leave timestamp and time value as nil if previous value of timestamp attribute was nil' do
      article.update_attribute(:published_at, nil)
      article.reload
      article.published_at_date = '28/11/2011'
      article.published_at_date.day.should == 28
      article.published_at_date.month.should == 11
      article.published_at_date.year.should == 2011
      article.published_at_time.should be_nil
      article.published_at.should be_nil
    end
  end

  describe '#published_at_time' do
    it 'should have virtual attribute published_at_time' do
      article.should respond_to(:published_at)
      article.should respond_to(:published_at_time)
    end

    it 'should return nil if timestamp attribute is nil' do
      article.update_attribute(:published_at, nil)
      article.reload
      article.published_at.should be_nil
      article.published_at_time.should be_nil
    end

    it 'should return time portion of timestamp formatted as string' do
      article.published_at_time.should be_a(String)
      article.published_at_time.should == '13:57'
    end
  end

  describe '#published_at_time=' do
    it 'should have virtual attribute published_at_time=' do
      article.should respond_to(:published_at)
      article.should respond_to(:published_at_time=)
    end

    it 'should assign nil to timestamp attribute when nil is passed' do
      article.published_at_time = nil
      article.published_at_time.should be_nil
      article.published_at.should be_nil
      article.save.should be_true
      article.reload.published_at.should be_nil
    end

    it 'should change only time portion of timestamp attribute' do
      article.published_at_time = '22:36'
      article.published_at_time.should == '22:36'
      article.published_at.should be_present
      article.published_at.strftime('%d/%m/%Y %H:%M').should == '22/12/2011 22:36'
    end

    it 'should assign nil if string parsing to time fails' do
      article.published_at_time = '22-36'
      article.published_at_time.should be_nil
      article.published_at.should be_nil
    end

    it 'should leave timestamp and time value as nil if previous value of timestamp attribute was nil' do
      article.update_attribute(:published_at, nil)
      article.reload
      article.published_at_time = '12:33'
      article.published_at_time.should == '12:33'
      article.published_at_date.should be_nil
      article.published_at.should be_nil
    end
  end

  describe 'when validating' do
    let(:sms){ FactoryGirl.create(:sms) }

    it 'should have before_type cast method defined and hold value' do
      sms.sent_at_date = 'asdf'
      sms.sent_at_date_before_type_cast.should == 'asdf'
      sms.sent_at_date.should be_nil

      sms.reload

      sms.sent_at_time = 'asdf'
      sms.sent_at_time_before_type_cast.should == 'asdf'
      sms.sent_at_time.should be_nil
    end

    #it 'should have sent_at_date and sent_at_time attributes invalid' do
    #  sms = Sms.new(:name => 'do it fast')
    #  sms.should_not be_valid
    #  sms.errors[:sent_at_date].should be_present
    #  sms.errors[:sent_at_time].should be_present
    #end
    #
    #it 'should have sent_at_date invalid when empty string is passed' do
    #  sms.sent_at_date = ''
    #  sms.should_not be_valid
    #  sms.errors.count.should == 1
    #  sms.errors[:sent_at_date].should be_present
    #  sms.errors[:sent_at_time].should be_empty
    #end
  end
end
