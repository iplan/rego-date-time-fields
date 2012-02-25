ActiveRecord::Schema.define(:version => 0) do

  create_table :articles do |t|
    t.string :title
    t.boolean :published
    t.integer :position
    t.timestamp :published_at
    t.timestamps
  end

  create_table :sms do |t|
    t.string :name
    t.integer :cost
    t.timestamp :sent_at
    t.timestamps
  end

end

