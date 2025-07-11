class SchedulingAvailability
  include ActiveModel::Model
  include ActiveModel::Attributes

  DAYS_OF_WEEK = %w[sunday monday tuesday wednesday thursday friday saturday].freeze
  TIME_SLOTS = %w[06:00 07:00 08:00 09:00 10:00 11:00 12:00 13:00 14:00 15:00 16:00 17:00 18:00 19:00 20:00 21:00 22:00 23:00].freeze

  attribute :day_of_week, :string
  attribute :available_slots, array: true, default: []

  validates :day_of_week, inclusion: { in: DAYS_OF_WEEK }
  validates :available_slots, presence: true

  def self.load_from_settings
    DAYS_OF_WEEK.map do |day|
      slots = Setting.get("scheduling_availability_#{day}")&.split(',') || []
      new(day_of_week: day, available_slots: slots)
    end
  end

  def save_to_settings
    Setting.set("scheduling_availability_#{day_of_week}", available_slots.join(','))
  end

  def available_at?(time_slot)
    available_slots.include?(time_slot)
  end

  def self.save_all_to_settings(availabilities)
    availabilities.each(&:save_to_settings)
  end

  def self.get_available_slots_for_date(date)
    day_name = date.strftime('%A').downcase
    availability = load_from_settings.find { |a| a.day_of_week == day_name }
    availability&.available_slots || []
  end

  def self.is_available_for_date_and_time?(date, time)
    slots = get_available_slots_for_date(date)
    time_slot = time.strftime('%H:%M')
    slots.include?(time_slot)
  end
end