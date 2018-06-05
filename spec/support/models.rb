class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include ActiveRecord::Loaded::Instances
  include ActiveRecord::ChangeDetector
end

class User < ApplicationRecord
  has_many :posts
end

class Post < ApplicationRecord
  belongs_to :user
end
