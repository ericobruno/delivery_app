require 'rails_helper'

RSpec.describe SchedulingConfiguration, type: :model do
  describe 'validações' do
    subject { build(:scheduling_configuration) }

    it { should validate_numericality_of(:max_days_ahead).is_greater_than(0).is_less_than_or_equal_to(365) }
    it { should validate_numericality_of(:same_day_intervals).is_greater_than(0).is_less_than_or_equal_to(10) }
    it { should validate_inclusion_of(:acceptance_mode).in_array(%w[manual automatic]) }
    it { should validate_inclusion_of(:time_unit).in_array(%w[minute hour]) }
    it { should validate_numericality_of(:time_interval).is_greater_than(0) }
    it { should validate_inclusion_of(:cancellation_unit).in_array(%w[hour day]) }
    it { should validate_numericality_of(:cancellation_value).is_greater_than(0) }
    it { should validate_inclusion_of(:production_unit).in_array(%w[minute hour]) }
    it { should validate_numericality_of(:production_value).is_greater_than(0) }
  end

  describe '.load_from_settings' do
    before do
      Setting.set('scheduling_enabled', 'on')
      Setting.set('scheduling_max_days', '90')
      Setting.set('same_day_scheduling_enabled', 'on')
      Setting.set('same_day_intervals', '2')
      Setting.set('closed_store_scheduling_enabled', 'off')
      Setting.set('acceptance_mode', 'manual')
      Setting.set('time_unit', 'hour')
      Setting.set('time_interval', '1')
      Setting.set('cancellation_unit', 'hour')
      Setting.set('cancellation_value', '24')
      Setting.set('production_unit', 'hour')
      Setting.set('production_value', '3')
    end

    it 'carrega configurações dos settings' do
      config = SchedulingConfiguration.load_from_settings
      
      expect(config.scheduling_enabled).to be true
      expect(config.max_days_ahead).to eq(90)
      expect(config.same_day_scheduling_enabled).to be true
      expect(config.same_day_intervals).to eq(2)
      expect(config.closed_store_scheduling_enabled).to be false
      expect(config.acceptance_mode).to eq('manual')
      expect(config.time_unit).to eq('hour')
      expect(config.time_interval).to eq(1)
      expect(config.cancellation_unit).to eq('hour')
      expect(config.cancellation_value).to eq(24)
      expect(config.production_unit).to eq('hour')
      expect(config.production_value).to eq(3)
    end
  end

  describe '#save_to_settings' do
    let(:config) { build(:scheduling_configuration) }

    it 'salva configurações nos settings' do
      config.save_to_settings
      
      expect(Setting.get('scheduling_enabled')).to eq('on')
      expect(Setting.get('scheduling_max_days')).to eq('90')
      expect(Setting.get('same_day_scheduling_enabled')).to eq('on')
      expect(Setting.get('same_day_intervals')).to eq('2')
      expect(Setting.get('closed_store_scheduling_enabled')).to eq('off')
      expect(Setting.get('acceptance_mode')).to eq('manual')
      expect(Setting.get('time_unit')).to eq('hour')
      expect(Setting.get('time_interval')).to eq('1')
      expect(Setting.get('cancellation_unit')).to eq('hour')
      expect(Setting.get('cancellation_value')).to eq('24')
      expect(Setting.get('production_unit')).to eq('hour')
      expect(Setting.get('production_value')).to eq('3')
    end
  end

  describe '#time_interval_in_minutes' do
    it 'retorna minutos quando time_unit é minute' do
      config = build(:scheduling_configuration, time_unit: 'minute', time_interval: 30)
      expect(config.time_interval_in_minutes).to eq(30)
    end

    it 'retorna minutos quando time_unit é hour' do
      config = build(:scheduling_configuration, time_unit: 'hour', time_interval: 2)
      expect(config.time_interval_in_minutes).to eq(120)
    end
  end

  describe '#cancellation_time_in_hours' do
    it 'retorna horas quando cancellation_unit é hour' do
      config = build(:scheduling_configuration, cancellation_unit: 'hour', cancellation_value: 12)
      expect(config.cancellation_time_in_hours).to eq(12)
    end

    it 'retorna horas quando cancellation_unit é day' do
      config = build(:scheduling_configuration, cancellation_unit: 'day', cancellation_value: 1)
      expect(config.cancellation_time_in_hours).to eq(24)
    end
  end

  describe '#production_time_in_hours' do
    it 'retorna horas quando production_unit é hour' do
      config = build(:scheduling_configuration, production_unit: 'hour', production_value: 2)
      expect(config.production_time_in_hours).to eq(2)
    end

    it 'retorna horas quando production_unit é minute' do
      config = build(:scheduling_configuration, production_unit: 'minute', production_value: 90)
      expect(config.production_time_in_hours).to eq(1.5)
    end
  end
end