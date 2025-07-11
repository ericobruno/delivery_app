import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { 
    updateUrl: String 
  }

  connect() {
    console.log("🚀 KANBAN CONTROLLER CONECTADO!")
    console.log("📊 Element:", this.element)
    console.log("🔗 Update URL:", this.updateUrlValue)
    
    // Verificar se o Sortable.js foi carregado
    if (typeof Sortable === 'undefined') {
      console.error("❌ Sortable.js não foi carregado!")
      return
    }
    
    console.log("✅ Sortable.js está disponível:", Sortable)
    
    // Inicializar após um pequeno delay para garantir que o DOM está pronto
    setTimeout(() => {
      this.initializeKanban()
    }, 100)
  }

  disconnect() {
    console.log("🔌 DESCONECTANDO Kanban Controller")
    if (this.sortables) {
      this.sortables.forEach(sortable => {
        try {
          sortable.destroy()
        } catch (e) {
          console.warn("Erro ao destruir sortable:", e)
        }
      })
    }
  }

  initializeKanban() {
    console.log("🎯 INICIALIZANDO KANBAN...")
    
    this.sortables = []
    const columns = this.element.querySelectorAll('.kanban-column')
    
    console.log(`📋 Encontradas ${columns.length} colunas`)
    
    if (columns.length === 0) {
      console.error("❌ Nenhuma coluna .kanban-column encontrada!")
      return
    }

    columns.forEach((column, index) => {
      const status = column.dataset.status
      const cardsContainer = column.querySelector('.kanban-cards')
      
      console.log(`🔍 Coluna ${index + 1}: status='${status}'`)
      console.log(`🔍 Cards container:`, cardsContainer)
      
      if (!cardsContainer) {
        console.warn(`⚠️ Container .kanban-cards não encontrado na coluna '${status}'`)
        return
      }

      try {
        console.log(`⚙️ Criando Sortable para coluna '${status}'...`)
        
        const sortable = Sortable.create(cardsContainer, {
          group: {
            name: 'kanban-cards',
            pull: true,
            put: true
          },
          animation: 150,
          ghostClass: 'sortable-ghost',
          chosenClass: 'sortable-chosen',
          dragClass: 'sortable-drag',
          forceFallback: false,
          fallbackTolerance: 0,
          emptyInsertThreshold: 5,
          
          // Eventos
          onStart: (evt) => {
            console.log("🎯 DRAG START:", evt.item)
            evt.item.style.opacity = '0.5'
            this.highlightValidColumns(evt.item.dataset.status)
          },
          
          onEnd: (evt) => {
            console.log("🎯 DRAG END:", evt)
            evt.item.style.opacity = '1'
            this.clearHighlights()
            this.handleMove(evt)
          },

          onMove: (evt) => {
            const draggedStatus = evt.dragged.dataset.status
            const targetColumn = evt.to.closest('.kanban-column')
            const targetStatus = targetColumn?.dataset.status
            
            if (!targetStatus) return false
            
            // Se for a mesma coluna, sempre permitir (reordenação)
            if (draggedStatus === targetStatus) {
              return true
            }
            
            const isValid = this.isValidTransition(draggedStatus, targetStatus)
            
            // Feedback visual imediato
            if (isValid) {
              targetColumn.classList.add('drop-valid')
              targetColumn.classList.remove('drop-invalid')
            } else {
              targetColumn.classList.add('drop-invalid')
              targetColumn.classList.remove('drop-valid')
              console.log(`🚫 MOVIMENTO BLOQUEADO: ${draggedStatus} → ${targetStatus}`)
            }
            
            return isValid
          },
          
          onUnchoose: (evt) => {
            // Limpar feedback visual quando parar de arrastar
            this.element.querySelectorAll('.kanban-column').forEach(col => {
              col.classList.remove('drop-valid', 'drop-invalid')
            })
          }
        })
        
        this.sortables.push(sortable)
        console.log(`✅ Sortable criado com sucesso para '${status}'`)
        
      } catch (error) {
        console.error(`❌ Erro ao criar Sortable para '${status}':`, error)
      }
    })
    
    console.log(`🎉 Kanban inicializado com ${this.sortables.length} colunas sortáveis`)
  }

  async handleMove(evt) {
    const orderId = evt.item.dataset.orderId
    const sourceColumn = evt.from.closest('.kanban-column')
    const targetColumn = evt.to.closest('.kanban-column')
    
    if (!sourceColumn || !targetColumn) {
      console.error("❌ Não foi possível encontrar colunas source/target")
      return
    }
    
    const sourceStatus = sourceColumn.dataset.status
    const targetStatus = targetColumn.dataset.status
    
    console.log(`📦 PROCESSANDO MOVIMENTO:`)
    console.log(`   📝 Pedido ID: ${orderId}`)
    console.log(`   📤 De: ${sourceStatus}`)
    console.log(`   📥 Para: ${targetStatus}`)
    
    // Se não mudou de coluna, não fazer nada
    if (sourceStatus === targetStatus) {
      console.log("⚠️ Mesmo status, nenhuma ação necessária")
      return
    }
    
    // Mostrar loading
    evt.item.classList.add('updating')
    
    try {
      const url = `${this.updateUrlValue}/${orderId}/update_status`
      console.log(`🌐 Fazendo requisição para: ${url}`)
      
      const response = await fetch(url, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken(),
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          status: targetStatus
        })
      })
      
      console.log(`📡 Resposta HTTP: ${response.status}`)
      
      if (response.ok) {
        const data = await response.json()
        console.log("✅ Status atualizado com sucesso:", data)
        
        // Atualizar o dataset do card
        evt.item.dataset.status = targetStatus
        
        // Atualizar badge visual
        this.updateCardBadge(evt.item, targetStatus)
        
        this.showToast("Status atualizado com sucesso!", "success")
        
      } else {
        const errorData = await response.json().catch(() => ({}))
        console.error("❌ Erro na resposta:", response.status, errorData)
        throw new Error(errorData.error || `HTTP ${response.status}`)
      }
      
    } catch (error) {
      console.error("❌ Erro ao atualizar status:", error)
      
      // Reverter movimento
      console.log("↩️ Revertendo movimento...")
      evt.from.appendChild(evt.item)
      
      // Mostrar erro mais detalhado
      const errorMessage = error.message || "Erro ao atualizar status"
      this.showToast(errorMessage, "error")
      
    } finally {
      evt.item.classList.remove('updating')
    }
  }

  isValidTransition(fromStatus, toStatus) {
    // Se é o mesmo status, sempre permitir (reordenação)
    if (fromStatus === toStatus) {
      return true
    }
    
    // Qualquer status pode ir para cancelado
    if (toStatus === 'cancelado') {
      return true
    }
    
    // Cancelado não pode sair (exceto para si mesmo)
    if (fromStatus === 'cancelado') {
      return false
    }
    
    // Entregue não pode sair (exceto para cancelado)
    if (fromStatus === 'entregue') {
      return false
    }
    
    // Definir fluxo normal e reverso permitido
    const forwardTransitions = {
      'novo': ['ag_aprovacao'],
      'ag_aprovacao': ['producao'],
      'producao': ['pronto'],
      'pronto': ['entregue']
    }
    
    const reverseTransitions = {
      'ag_aprovacao': ['novo'],
      'producao': ['ag_aprovacao'],
      'pronto': ['producao'],
      'entregue': ['pronto']
    }
    
    // Verificar se é transição válida (forward ou reverse)
    const isForward = forwardTransitions[fromStatus]?.includes(toStatus)
    const isReverse = reverseTransitions[fromStatus]?.includes(toStatus)
    
    return isForward || isReverse || false
  }

  highlightValidColumns(currentStatus) {
    const validStatuses = this.getValidTransitions(currentStatus)
    const columns = this.element.querySelectorAll('.kanban-column')
    
    columns.forEach(column => {
      const status = column.dataset.status
      if (validStatuses.includes(status)) {
        column.classList.add('valid-drop')
      } else if (status !== currentStatus) {
        column.classList.add('invalid-drop')
      }
    })
  }

  clearHighlights() {
    const columns = this.element.querySelectorAll('.kanban-column')
    columns.forEach(column => {
      column.classList.remove('valid-drop', 'invalid-drop')
    })
  }

  getValidTransitions(status) {
    // Cancelado não pode sair
    if (status === 'cancelado') {
      return []
    }
    
    // Entregue só pode ir para cancelado
    if (status === 'entregue') {
      return ['cancelado']
    }
    
    // Para outros status, definir transições forward, reverse e cancelado
    const transitions = {
      'novo': ['ag_aprovacao', 'cancelado'],
      'ag_aprovacao': ['novo', 'producao', 'cancelado'],
      'producao': ['ag_aprovacao', 'pronto', 'cancelado'],
      'pronto': ['producao', 'entregue', 'cancelado']
    }
    
    return transitions[status] || []
  }

  updateCardBadge(card, newStatus) {
    const badge = card.querySelector('.status-badge')
    if (badge) {
      const statusInfo = this.getStatusInfo(newStatus)
      badge.textContent = statusInfo.label
      badge.className = `badge status-badge ${statusInfo.class}`
    }
  }

  getStatusInfo(status) {
    const statusMap = {
      'novo': { label: 'Novo', class: 'bg-primary' },
      'ag_aprovacao': { label: 'Ag. Aprovação', class: 'bg-warning text-dark' },
      'producao': { label: 'Produção', class: 'bg-info' },
      'pronto': { label: 'Pronto', class: 'bg-success' },
      'entregue': { label: 'Entregue', class: 'bg-dark' },
      'cancelado': { label: 'Cancelado', class: 'bg-danger' }
    }
    
    return statusMap[status] || { label: status, class: 'bg-secondary' }
  }

  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.getAttribute('content') : ''
  }

  showToast(message, type = 'info') {
    console.log(`🔔 Toast: ${message} (${type})`)
    
    // Criar toast simples
    const toast = document.createElement('div')
    toast.className = `alert alert-${type === 'error' ? 'danger' : type} position-fixed`
    toast.style.cssText = `
      top: 20px; 
      right: 20px; 
      z-index: 9999; 
      min-width: 300px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      border-radius: 8px;
    `
    toast.textContent = message
    
    document.body.appendChild(toast)
    
    // Remover após 3 segundos
    setTimeout(() => {
      toast.remove()
    }, 3000)
  }
} 