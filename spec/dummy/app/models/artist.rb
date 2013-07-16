class Artist < ActiveRecord::Base
  if Rails.version < "4.0.0"
    attr_accessible :name, :slug
  end
  acts_as_loggable

  has_many :users, through: :followings
  has_many :followings

end
