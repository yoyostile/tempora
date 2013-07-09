class Following < ActiveRecord::Base
  attr_accessible :user, :artist
  belongs_to :user
  belongs_to :artist
end
