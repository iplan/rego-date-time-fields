FactoryGirl.define do

  factory :article do |f|
    f.sequence(:title) {|n| "Article - #{n}"}
  end

  factory :sms do |f|
    f.sequence(:name) {|n| "Sms - #{n}"}
    f.cost 22
    f.sent_at DateTime.strptime('22/12/2011 13:57', '%d/%m/%Y %H:%M')
  end
  
end

