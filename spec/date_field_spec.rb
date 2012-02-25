require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "form_for().date_field", :type => :view do

  it "should render an inline template" do
    render :inline => "<%= who%> rocks!", :locals => {:who => "Alex"}
    rendered.should == "Alex rocks!"
  end

  describe "with default type" do
    let(:sms){ FactoryGirl.create(:sms) }
    let(:template){ FileMacros.load_view('sms_form_with_date') }

    before :each do
      render(:inline => template, :locals => { :sms => sms })
      puts rendered
    end

    it "should render successfully" do
      rendered.should_not be_nil
    end

    it "should have a date input" do
      rendered.should have_tag('input')
      rendered.should have_tag('input', :with => {:name => 'sms[sent_at_date]'})
    end

    it "should have a javacript tag initializing jquery ui datepicker" do
      rendered.should have_tag('script')
      rendered.should have_tag('script', :with => {:type => 'text/javascript'})
      rendered.should have_tag('script', :text => /\)\.datepicker/i)
    end

  end

end
