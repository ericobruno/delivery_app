class SchedulingConfiguration
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :scheduling_enabled, :boolean, default: false
  attribute :max_days_ahead, :integer, default: 90
  attribute :same_day_scheduling_enabled, :boolean, default: false
  attribute :same_day_intervals, :integer, default: 2
  attribute :closed_store_scheduling_enabled, :boolean, default: false
  attribute :acceptance_mode, :string, default: 'manual'
  attribute :time_unit, :string, default: 'hour'
  attribute :time_interval, :integer, default: 1
  attribute :cancellation_unit, :string, default: 'hour'
  attribute :cancellation_value, :integer, default: 24
  attribute :production_unit, :string, default: 'hour'
  attribute :production_value, :integer, default: 3

  validates :max_days_ahead, numericality: { greater_than: 0, less_than_or_equal_to: 365 }
  validates :same_day_intervals, numericality: { greater_than: 0, less_than_or_equal_to: 10 }
  validates :acceptance_mode, inclusion: { in: %w[manual automatic] }
  validates :time_unit, inclusion: { in: %w[minute hour] }
  validates :time_interval, numericality: { greater_than: 0 }
  validates :cancellation_unit, inclusion: { in: %w[hour day] }
  validates :cancellation_value, numericality: { greater_than: 0 }
  validates :production_unit, inclusion: { in: %w[minute hour] }
  validates :production_value, numericality: { greater_than: 0 }

  def self.load_from_settings
    new(
      scheduling_enabled: Setting.get('scheduling_enabled') == 'on',
      max_days_ahead: Setting.get_with_default('scheduling_max_days', 90).to_i,
      same_day_scheduling_enabled: Setting.get('same_day_scheduling_enabled') == 'on',
      same_day_intervals: Setting.get_with_default('same_day_intervals', 2).to_i,
      closed_store_scheduling_enabled: Setting.get('closed_store_scheduling_enabled') == 'on',
      acceptance_mode: Setting.get_with_default('acceptance_mode', 'manual'),
      time_unit: Setting.get_with_default('time_unit', 'hour'),
      time_interval: Setting.get_with_default('time_interval', 1).to_i,
      cancellation_unit: Setting.get_with_default('cancellation_unit', 'hour'),
      cancellation_value: Setting.get_with_default('cancellation_value', 24).to_i,
      production_unit: Setting.get_with_default('production_unit', 'hour'),
      production_value: Setting.get_with_default('production_value', 3).to_i
    )
  end

  def save_to_settings
    Setting.set('scheduling_enabled', scheduling_enabled ? 'on' : 'off')
    Setting.set('scheduling_max_days', max_days_ahead.to_s)
    Setting.set('same_day_scheduling_enabled', same_day_scheduling_enabled ? 'on' : 'off')
    Setting.set('same_day_intervals', same_day_intervals.to_s)
    Setting.set('closed_store_scheduling_enabled', closed_store_scheduling_enabled ? 'on' : 'off')
    Setting.set('acceptance_mode', acceptance_mode)
    Setting.set('time_unit', time_unit)
    Setting.set('time_interval', time_interval.to_s)
    Setting.set('cancellation_unit', cancellation_unit)
    Setting.set('cancellation_value', cancellation_value.to_s)
    Setting.set('production_unit', production_unit)
    Setting.set('production_value', production_value.to_s)
  end

  def time_interval_in_minutes
    case time_unit
    when 'minute'
      time_interval
    when 'hour'
      time_interval * 60
    else
      60
    end
  end

  def cancellation_time_in_hours
    case cancellation_unit
    when 'hour'
      cancellation_value
    when 'day'
      cancellation_value * 24
    else
      24
    end
  end

  def production_time_in_hours
    case production_unit
    when 'minute'
      production_value / 60.0
    when 'hour'
      production_value
    else
      3
    end
  end
end