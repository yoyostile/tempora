class User < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name, :password
  acts_as_logger
  has_many :followings, dependent: :destroy
  has_many :artists, through: :following
end
