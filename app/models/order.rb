class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items
  # description: text

  validate :scheduled_for_cannot_be_in_the_past, if: :scheduled_for_changed?
  validates :customer, presence: true
  validates :status, presence: true, inclusion: { in: %w[novo ag_aprovacao producao pronto entregue cancelado] }
  validate :must_have_at_least_one_item, unless: :status_only_update?

  before_create :set_default_status

  def scheduled_for_cannot_be_in_the_past
    if scheduled_for.present? && scheduled_for < Time.current
      errors.add(:scheduled_for, "não pode ser no passado")
    end
  end

  def must_have_at_least_one_item
    if order_items.empty? || order_items.all? { |item| item.marked_for_destruction? }
      errors.add(:base, 'O pedido deve ter pelo menos um item.')
    end
  end

  private

  def status_only_update?
    # Se está atualizando um registro existente (não novo)
    # E só o status foi alterado (não os order_items)
    persisted? && changed_attributes.keys == ['status']
  end

  def set_default_status
    if self.status.blank?
      self.status = Setting.aceite_automatico? ? 'producao' : 'novo'
    end
  end
end
