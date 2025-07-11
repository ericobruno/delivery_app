FactoryBot.define do
  factory :scheduling_configuration do
    scheduling_enabled { true }
    max_days_ahead { 90 }
    same_day_scheduling_enabled { true }
    same_day_intervals { 2 }
    closed_store_scheduling_enabled { false }
    acceptance_mode { 'manual' }
    time_unit { 'hour' }
    time_interval { 1 }
    cancellation_unit { 'hour' }
    cancellation_value { 24 }
    production_unit { 'hour' }
    production_value { 3 }
  end
end