class Order < ApplicationRecord
  include Schedulable
  
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items
  # description: text

  validates :customer, presence: true
  validates :status, presence: true, inclusion: { in: %w[novo ag_aprovacao producao pronto entregue cancelado] }
  validate :must_have_at_least_one_item, unless: :status_only_update?
  validate :scheduled_time_must_be_available, if: :scheduled_for_changed?

  before_create :set_default_status
  after_save :move_to_production_if_needed, if: :saved_change_to_scheduled_for?

  def must_have_at_least_one_item
    if order_items.empty? || order_items.all? { |item| item.marked_for_destruction? }
      errors.add(:base, 'O pedido deve ter pelo menos um item.')
    end
  end

  def scheduled_time_must_be_available
    return unless scheduled_for.present?
    return unless Setting.scheduling_enabled?

    unless SchedulingAvailability.is_available_for_date_and_time?(scheduled_for.to_date, scheduled_for)
      errors.add(:scheduled_for, "horário não disponível para agendamento")
    end
  end

  def move_to_production_if_needed
    return unless scheduled_for.present?
    return unless should_move_to_production?
    return if status == 'producao' || status == 'pronto' || status == 'entregue'

    update_column(:status, 'producao')
  end

  private

  def status_only_update?
    # Se está atualizando um registro existente (não novo)
    # E só o status foi alterado (não os order_items)
    persisted? && changed_attributes.keys == ['status']
  end

  def set_default_status
    if self.status.blank?
      self.status = Setting.automatic_acceptance_enabled? ? 'producao' : 'novo'
    end
  end
end
