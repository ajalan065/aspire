class User < ApplicationRecord
  rolify

  has_many :loans

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates_uniqueness_of :email

  after_create :assign_default_role

  def assign_default_role
    self.add_role(:customer) if self.roles.blank?
  end
end
