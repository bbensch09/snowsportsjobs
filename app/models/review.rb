class Review < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :reviewer, class_name: 'User', foreign_key: 'reviewer_id'
  belongs_to :lesson

  def display_name
    if self.reviewer.email == "brian@snowschoolers.com"
        sample_names = ['Ken','Bryan','Don','Carl','Bob','Aaron','Ashley','Kevin','Robert','Tessa','Gary','Dee','Ryan','Sean']
        return sample_names[rand(14)]
    elsif self.lesson && self.lesson.requester_name
      return self.lesson.requester_name.split(" ").first
    else
      return "Anonymous"
    end
  end

end
