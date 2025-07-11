require 'rails_helper'

RSpec.describe OrderSchedulingService, type: :service do
  let(:scheduling_service) { instance_double(SchedulingService) }
  let(:service) { described_class.new(scheduling_service) }
  let(:customer) { create(:customer) }
  let(:order) { create(:order, customer: customer) }

  before do
    allow(scheduling_service).to receive(:validate_scheduling_time).and_return(true)
    allow(scheduling_service).to receive(:can_cancel_order?).and_return(true)
    allow(scheduling_service).to receive(:should_move_order_to_production?).and_return(false)
  end

  describe '#schedule_order' do
    let(:scheduled_time) { 1.hour.from_now }

    context 'quando o horário é válido' do
      before do
        allow(scheduling_service).to receive(:validate_scheduling_time).with(scheduled_time).and_return(true)
      end

      it 'agenda o pedido com sucesso' do
        result = service.schedule_order(order, scheduled_time)
        
        expect(result).to be true
        expect(order.scheduled_for).to eq(scheduled_time)
      end

      it 'define o status inicial baseado no modo de aceite' do
        allow(scheduling_service).to receive(:acceptance_mode).and_return('automatic')
        
        service.schedule_order(order, scheduled_time)
        
        expect(order.status).to eq('producao')
      end
    end

    context 'quando o horário é inválido' do
      before do
        allow(scheduling_service).to receive(:validate_scheduling_time).with(scheduled_time).and_return(false)
      end

      it 'retorna false' do
        result = service.schedule_order(order, scheduled_time)
        
        expect(result).to be false
      end
    end
  end

  describe '#cancel_scheduled_order' do
    context 'quando o cancelamento é permitido' do
      before do
        allow(scheduling_service).to receive(:can_cancel_order?).with(order).and_return(true)
      end

      it 'cancela o pedido com sucesso' do
        result = service.cancel_scheduled_order(order)
        
        expect(result).to be true
        expect(order.status).to eq('cancelado')
      end
    end

    context 'quando o cancelamento não é permitido' do
      before do
        allow(scheduling_service).to receive(:can_cancel_order?).with(order).and_return(false)
      end

      it 'retorna false' do
        result = service.cancel_scheduled_order(order)
        
        expect(result).to be false
      end
    end
  end

  describe '#move_orders_to_production' do
    let!(:scheduled_order) { create(:order, status: 'novo', scheduled_for: 2.hours.from_now) }
    let!(:regular_order) { create(:order, status: 'novo', scheduled_for: nil) }

    before do
      allow(scheduling_service).to receive(:should_move_order_to_production?).with(scheduled_order).and_return(true)
      allow(scheduling_service).to receive(:should_move_order_to_production?).with(regular_order).and_return(false)
    end

    it 'move apenas pedidos agendados que devem ir para produção' do
      count = service.move_orders_to_production
      
      expect(count).to eq(1)
      expect(scheduled_order.reload.status).to eq('producao')
      expect(regular_order.reload.status).to eq('novo')
    end
  end

  describe '#validate_scheduling_time' do
    let(:scheduled_time) { 1.hour.from_now }

    context 'quando o horário é válido' do
      before do
        allow(scheduling_service).to receive(:validate_scheduling_time).with(scheduled_time).and_return(true)
      end

      it 'retorna true' do
        result = service.validate_scheduling_time(scheduled_time)
        expect(result).to be true
      end
    end

    context 'quando o horário é inválido' do
      before do
        allow(scheduling_service).to receive(:validate_scheduling_time).with(scheduled_time).and_return(false)
      end

      it 'retorna false' do
        result = service.validate_scheduling_time(scheduled_time)
        expect(result).to be false
      end
    end
  end

  describe '#get_available_slots_for_date_range' do
    let(:start_date) { Date.current }
    let(:end_date) { Date.current + 2.days }

    before do
      allow(scheduling_service).to receive(:available_slots_for_date).with(start_date).and_return(['09:00', '10:00'])
      allow(scheduling_service).to receive(:available_slots_for_date).with(start_date + 1.day).and_return(['14:00', '15:00'])
      allow(scheduling_service).to receive(:available_slots_for_date).with(end_date).and_return([])
    end

    it 'retorna slots disponíveis para o intervalo de datas' do
      result = service.get_available_slots_for_date_range(start_date, end_date)
      
      expect(result).to eq({
        start_date => ['09:00', '10:00'],
        start_date + 1.day => ['14:00', '15:00']
      })
    end
  end
end