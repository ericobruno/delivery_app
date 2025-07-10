class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  # Callbacks
  before_validation :normalize_email

  # Instance methods
  def display_name
    name.present? ? name : email.split('@').first
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end 