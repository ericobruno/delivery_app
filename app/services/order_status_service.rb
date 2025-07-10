class OrderStatusService
  def initialize(order)
    @order = order
  end

  def approve!
    return false unless can_approve?
    
    @order.update!(status: 'novo')
    true
  end

  def can_approve?
    @order.status == 'ag_aprovacao'
  end

  def next_status
    case @order.status
    when 'novo'
      'em_preparacao'
    when 'em_preparacao'
      'pronto'
    when 'pronto'
      'entregue'
    else
      nil
    end
  end

  def advance_status!
    return false unless next_status
    
    @order.update!(status: next_status)
    true
  end

  def cancel!
    return false if @order.status == 'entregue'
    
    @order.update!(status: 'cancelado')
    true
  end

  def status_transitions
    case @order.status
    when 'ag_aprovacao'
      ['novo']
    when 'novo'
      ['em_preparacao', 'cancelado']
    when 'em_preparacao'
      ['pronto', 'cancelado']
    when 'pronto'
      ['entregue', 'cancelado']
    when 'entregue'
      []
    when 'cancelado'
      []
    else
      []
    end
  end
end