class Following < ActiveRecord::Base
  if Rails.version < "4.0.0"
    attr_accessible :user, :artist
  end
  belongs_to :user
  belongs_to :artist
end
