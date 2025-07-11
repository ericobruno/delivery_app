class OrderStatusService
  def initialize(order)
    @order = order
  end

  def approve!
    return false unless can_approve?
    
    @order.update!(status: 'producao')
    true
  end

  def can_approve?
    @order.status == 'novo' || @order.status == 'ag_aprovacao'
  end

  def next_status
    case @order.status
    when 'novo'
      'ag_aprovacao'
    when 'ag_aprovacao'
      'producao'
    when 'producao'
      'pronto'
    when 'pronto'
      'entregue'
    when 'entregue'
      nil # Status final
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
    return false if ['entregue', 'cancelado'].include?(@order.status)
    
    @order.update!(status: 'cancelado')
    true
  end

  def status_transitions
    case @order.status
    when 'novo'
      ['ag_aprovacao', 'cancelado']
    when 'ag_aprovacao'
      ['novo', 'producao', 'cancelado']
    when 'producao'
      ['ag_aprovacao', 'pronto', 'cancelado']
    when 'pronto'
      ['producao', 'entregue', 'cancelado']
    when 'entregue'
      ['cancelado'] # Pode apenas ser cancelado
    when 'cancelado'
      [] # Status final
    else
      []
    end
  end
end