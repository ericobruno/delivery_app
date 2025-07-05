class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items
  # description: text

  validate :scheduled_for_cannot_be_in_the_past
  validates :customer, presence: true
  validates :status, presence: true, inclusion: { in: %w[novo ag_aprovacao em_preparacao pronto entregue cancelado] }
  validate :must_have_at_least_one_item

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

  def set_default_status
    if self.status.blank?
      self.status = Setting.aceite_automatico? ? 'novo' : 'ag_aprovacao'
    end
  end
end
