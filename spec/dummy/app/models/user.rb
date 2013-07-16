class User < ActiveRecord::Base
  if Rails.version < "4.0.0"
    attr_accessible :email, :first_name, :last_name, :password
  end
  acts_as_logger
  has_many :followings, dependent: :destroy
  has_many :artists, through: :followings
end
