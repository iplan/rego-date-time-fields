require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "form_for().time_field", :type => :view do

  describe "with default type" do
    let(:sms){ FactoryGirl.create(:sms, :sent_at => DateTime.strptime('22/12/2011 14:45', '%d/%m/%Y %H:%M')) }
    let(:tpl1){ render(:inline => FileMacros.load_view('sms_form_with_time'), :locals => { :sms => sms, :time_field_options => {:from_hour => 10, :to_hour => 22} }) } # time field from 10:00 to 22:00
    let(:tpl2){ render(:inline => FileMacros.load_view('sms_form_with_time'), :locals => { :sms => sms, :time_field_options => {:from_hour => 9, :to_hour => 7} }) } # time field from 9:00 to 7:00
    let(:tpl_24h){ render(:inline => FileMacros.load_view('sms_form_with_time'), :locals => { :sms => sms, :time_field_options => {:from_hour => 11, :to_hour => 11} }) } # time field from 11:00 to 10:45

    it "should render successfully" do
      tpl1.should_not be_nil
      tpl2.should_not be_nil
      tpl_24h.should_not be_nil
    end

    it "should have a time input" do
      tpl1.should have_tag('select')
      tpl1.should have_tag('select', :with => {:name => 'sms[sent_at_time]'})

      tpl2.should have_tag('select')
      tpl2.should have_tag('select', :with => {:name => 'sms[sent_at_time]'})

      tpl_24h.should have_tag('select')
      tpl_24h.should have_tag('select', :with => {:name => 'sms[sent_at_time]'})
    end

    it 'should have time input select options' do
      tpl1.should have_tag('select') do
        %w{10:00  15:45  21:45  22:00}.each do |hour|
          with_option hour
        end
        %w{09:00  09:45  22:15  22:45}.each do |hour|
          without_option hour
        end
        with_option '14:45', :with => {:selected => 'selected'}
      end
    end

    it 'should do 24 hours cycle count' do
      tpl2.should have_tag('select') do
        %w{09:00  15:45  21:45  22:00  00:00  00:15  03:15  06:15  06:45  07:00}.each do |hour|
          with_option hour
        end
        %w{08:00  08:45  07:15  07:45}.each do |hour|
          without_option hour
        end
      end
    end

    it 'should do full 24 hours cycle' do
      puts tpl_24h
      tpl_24h.should have_tag('select') do
        %w{09:00  15:45  21:45  22:00  00:00  00:15  03:15  06:15  06:45  07:00  08:30  10:45  11:00}.each do |hour|
          with_option hour
        end
      end
    end
  end

end
