module Schedulable
  extend ActiveSupport::Concern

  included do
    validates :scheduled_for, presence: true, if: :scheduling_required?
    validate :scheduled_for_cannot_be_in_the_past, if: :scheduled_for_changed?
    validate :scheduled_for_must_be_within_availability_window, if: :scheduled_for_changed?
  end

  def scheduling_required?
    Setting.scheduling_enabled?
  end

  def scheduled_for_cannot_be_in_the_past
    if scheduled_for.present? && scheduled_for < Time.current
      errors.add(:scheduled_for, "não pode ser no passado")
    end
  end

  def scheduled_for_must_be_within_availability_window
    return unless scheduled_for.present?
    
    max_days = Setting.get_with_default('scheduling_max_days', 90).to_i
    max_date = Date.current + max_days.days
    
    if scheduled_for.to_date > max_date
      errors.add(:scheduled_for, "não pode ser agendado para mais de #{max_days} dias à frente")
    end
  end

  def can_be_cancelled?
    return true unless scheduled_for.present?
    
    cancellation_hours = Setting.get_with_default('cancellation_hours', 24).to_i
    cancellation_deadline = scheduled_for - cancellation_hours.hours
    
    Time.current < cancellation_deadline
  end

  def should_move_to_production?
    return false unless scheduled_for.present?
    
    production_hours = Setting.get_with_default('production_hours', 3).to_i
    production_deadline = scheduled_for - production_hours.hours
    
    Time.current >= production_deadline
  end
end