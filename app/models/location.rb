class Location < ActiveRecord::Base
  has_and_belongs_to_many :instructors  #, dependent: :destroy
  has_one :user
end
