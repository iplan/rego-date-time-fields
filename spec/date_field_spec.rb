require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "form_for().date_field", :type => :view do

  it "should render an inline template" do
    render :inline => "<%= who%> rocks!", :locals => {:who => "Alex"}
    rendered.should == "Alex rocks!"
  end

  describe "with default type" do
    let(:sms){ FactoryGirl.create(:sms) }
    let(:template){ render(:inline => FileMacros.load_view('sms_form_with_date'), :locals => { :sms => sms }) }
    let(:tpl_custom_format){ render(:inline => FileMacros.load_view('sms_form_with_date'), :locals => { :sms => sms, :date_format => '%d/%m/%Y' }) }

    it "should render successfully" do
      template.should_not be_nil
    end

    it "should have a date input" do
      template.should have_tag('input')
      template.should have_tag('input', :with => {:name => 'sms[sent_at_date]'})
    end

    it "should have a javascript tag initializing jquery ui datepicker" do
      template.should have_tag('script')
      template.should have_tag('script', :with => {:type => 'text/javascript'})
      template.should have_tag('script', :text => /\)\.datepicker/i)
    end

    it 'should have value inside it from model date' do
      template.should have_tag('input', :with => {:name => 'sms[sent_at_date]', :value => sms.sent_at_date.strftime(I18n.t('date.formats.default'))})
      template.should have_tag('script', :text => /#{DateTimeFields::RubyToJqueryDateFormatConvertor.convert(I18n.t('date.formats.default'))}/i)
      tpl_custom_format.should have_tag('input', :with => {:name => 'sms[sent_at_date]', :value => sms.sent_at_date.strftime('%d/%m/%Y')})
      tpl_custom_format.should have_tag('script', :text => /#{DateTimeFields::RubyToJqueryDateFormatConvertor.convert('%d/%m/%Y')}/i)
    end

  end

end
