class User < ApplicationRecord
  has_secure_password validations: false
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # setting required: true in the frontend only checks client-side
  # so we need to validate server-side
  validates :email_address, presence: true, uniqueness: { message: "is already registered!" }
  validates :password, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :create
  validate :password_complexity, if: :password_digest_changed?
  validate :passwords_match, if: :password_digest_changed?

  # prevent users from setting blank string when updating profile
  validates :course, length: { minimum: 1 }, allow_nil: true, if: -> { course.present? }
  validates :institution, length: { minimum: 1 }, allow_nil: true, if: -> { institution.present? }
  validates :year_of_study, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 6 }, allow_nil: true, if: -> { year_of_study.present? }

  # normalize blank strings to nil
  before_validation :normalize_profile_fields

  private

  def normalize_profile_fields
    self.course = nil if course.blank?
    self.institution = nil if institution.blank?
    self.year_of_study = nil if year_of_study.blank?
  end

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
