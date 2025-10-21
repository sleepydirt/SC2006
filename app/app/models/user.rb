class User < ApplicationRecord
  has_secure_password validations: false
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # setting required: true in the frontend only checks client-side
  # so we need to validate server-side
  validates :email_address, presence: true, uniqueness: { message: "is already registered!" }
  validates :password, presence: true
  validates :password_confirmation, presence: true
  validate :password_complexity
  validate :passwords_match

  private

  # helper function to enforce password complexity server-side
  def password_complexity
    if password.blank?
      errors.add(:base, "Password cannot be blank!")
      return
    end

    if password.length < 8
      errors.add(:base, "Password must contain at least 8 characters!")
      return
    end

    unless password.match?(/[A-Z]/)
      errors.add(:base, "Password must contain at least 1 uppercase letter!")
      return
    end

    unless password.match?(/[0-9]/)
      errors.add(:base, "Password must contain at least 1 number!")
      return
    end

    unless password.match?(/[^A-Za-z0-9]/)
      errors.add(:base, "Password must contain at least 1 special character!")
      return
    end

    unless password.match?(/^[A-Za-z0-9]+$/).nil? || password.match?(/[A-Za-z0-9]/)
      errors.add(:base, "Password cannot contain non-alphanumeric characters!")
    end
  end

  def passwords_match
    if password_confirmation.blank?
      errors.add(:base, "Password confirmation cannot be blank!")
      return
    end

    if password.present? && password_confirmation.present? && password != password_confirmation
      errors.add(:base, "Passwords do not match!")
    end
  end
end
