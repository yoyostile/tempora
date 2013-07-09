class Artist < ActiveRecord::Base
  attr_accessible :name, :slug
  acts_as_loggable
end
