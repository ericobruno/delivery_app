class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  # Cache para melhorar performance
  CACHE_EXPIRATION = 5.minutes

  def self.get(key)
    Rails.cache.fetch("setting_#{key}", expires_in: CACHE_EXPIRATION) do
      find_by(key: key)&.value
    end
  end

  def self.set(key, value)
    record = find_or_initialize_by(key: key)
    record.value = value
    record.save!
    
    # Invalidar cache
    Rails.cache.delete("setting_#{key}")
  end

  def self.aceite_automatico?
    get('aceite_automatico') == 'on'
  end

  def self.aceite_automatico_force_reload!
    Rails.cache.delete("setting_aceite_automatico")
    aceite_automatico?
  end

  # Método para verificar se uma configuração existe
  def self.setting_exists?(key)
    exists?(key: key)
  end

  # Método para obter configuração com valor padrão
  def self.get_with_default(key, default_value = nil)
    get(key) || default_value
  end

  # Métodos para agendamento
  def self.scheduling_enabled?
    get('scheduling_enabled') == 'on'
  end

  def self.same_day_scheduling_enabled?
    get('same_day_scheduling_enabled') == 'on'
  end

  def self.closed_store_scheduling_enabled?
    get('closed_store_scheduling_enabled') == 'on'
  end

  def self.automatic_acceptance_enabled?
    get('acceptance_mode') == 'automatic'
  end
end 