class Sport < ApplicationRecord
  has_and_belongs_to_many :instructor
end
