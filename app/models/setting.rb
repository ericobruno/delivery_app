class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  def self.get(key)
    find_by(key: key)&.value
  end

  def self.set(key, value)
    record = find_or_initialize_by(key: key)
    record.value = value
    record.save!
    # Força o reload do cache
    Rails.cache.delete("setting_#{key}")
  end

  def self.aceite_automatico?
    # Força a recarga do valor do banco
    get('aceite_automatico') == 'on'
  end
end 