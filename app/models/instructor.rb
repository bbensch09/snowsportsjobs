class Instructor < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :locations
  has_many :lesson_actions
  has_many :calendar_blocks
  after_create :send_admin_notification
  validates :username, :first_name, :last_name, :certification, :sport, :intro, presence: true
  has_attached_file :avatar, styles: { large: "400x400>", thumb: "80x80>" },  default_url: "https://s3.amazonaws.com/snowschoolers/cd-sillouhete.jpg",
        :storage => :s3,
        :bucket => 'snowschoolers'
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/


  def name
    self.first_name + " " + self.last_name
  end

  def to_param
        [id, name.parameterize].join("-")
  end

  def send_admin_notification
      @instructor = Instructor.last
      LessonMailer.new_instructor_application_received(@instructor).deliver
      puts "an admin notification has been sent."
  end

end
