class User < ActiveRecord::Base
  #has_secure_password
  validates :uid,   :presence => true, 
                    :uniqueness => true
  validates :pass,  :presence => true
end