class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :comments, dependent: :destroy
  has_one_attached :avatar
  validates :username, presence: :true, uniqueness: {case_sensitive: false}
  validate :validate_username

  attr_writer :login

  def validate_username
    errors.add(:username, :invalid) if User.where(email: username).exists?

  end

  def login
    @login || username || email

  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(['lower(username) = :value OR lower(email) = :value', {
        value: login.downcase
      }]).first

    elsif conditions.key?(:username) || conditions.key?(:email)
      where(conditions.to_h).first
    end

  end

  # aayushstha25@gmail.com -> self.email.split('@') -> ["aayushstha25 ", "gmail.com"] -> [0] -> "aayush".capitalize -> "Dean"
  #This function allows us to split our email after the @ sign and splits the email into two values where the zeroeth position value is taken and capitalized

  # def username
  #   return email.split("@")[0].capitalize
  # end

  def comment_created
    self.number_of_comments = number_of_comments + 1
    save
    return number_of_comments
  end
end
