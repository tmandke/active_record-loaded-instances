ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string :name, :null => false
    t.timestamps
  end

  create_table :posts, :force => true do |t|
    t.references :user
    t.text :text
    t.timestamps
  end
end
