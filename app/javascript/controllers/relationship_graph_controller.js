import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    familyId: Number
  }

  connect() {
    this.loadGraphData()
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener('resize', this.handleResize)
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize)
  }

  handleResize() {
    if (this.data) {
      this.renderGraph(this.data)
    }
  }

  async loadGraphData() {
    try {
      const response = await fetch(this.urlValue)
      this.data = await response.json()
      this.renderGraph(this.data)
    } catch (error) {
      console.error('Failed to load relationship graph data:', error)
      this.element.innerHTML = '<div class="text-center text-red-500">Failed to load relationship map</div>'
    }
  }

  renderGraph(data) {
    const { members, relationships } = data
    const container = this.element
    const width = container.offsetWidth
    const height = container.offsetHeight || 400

    // Clear previous content
    container.innerHTML = ''

    // Create SVG
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
    svg.setAttribute('width', '100%')
    svg.setAttribute('height', '100%')
    svg.setAttribute('viewBox', `0 0 ${width} ${height}`)
    container.appendChild(svg)

    // Calculate positions in a circle
    const centerX = width / 2
    const centerY = height / 2
    const radius = Math.min(width, height) / 2 - 60

    const positions = {}
    members.forEach((member, index) => {
      const angle = (2 * Math.PI * index) / members.length - Math.PI / 2
      positions[member.id] = {
        x: centerX + radius * Math.cos(angle),
        y: centerY + radius * Math.sin(angle)
      }
    })

    // Draw relationship lines first (so they appear behind nodes)
    relationships.forEach(rel => {
      const source = positions[rel.source]
      const target = positions[rel.target]

      if (source && target) {
        const line = document.createElementNS('http://www.w3.org/2000/svg', 'line')
        line.setAttribute('x1', source.x)
        line.setAttribute('y1', source.y)
        line.setAttribute('x2', target.x)
        line.setAttribute('y2', target.y)
        line.setAttribute('stroke', rel.health_color)
        line.setAttribute('stroke-width', '4')
        line.setAttribute('stroke-linecap', 'round')
        line.setAttribute('data-relationship-id', rel.id)
        line.setAttribute('data-display-name', rel.display_name)
        line.style.cursor = 'pointer'
        line.style.transition = 'stroke-width 0.2s'

        line.addEventListener('mouseenter', () => {
          line.setAttribute('stroke-width', '6')
        })
        line.addEventListener('mouseleave', () => {
          line.setAttribute('stroke-width', '4')
        })
        line.addEventListener('click', () => {
          this.openAssessment(rel.id)
        })

        svg.appendChild(line)
      }
    })

    // Draw member bubbles
    members.forEach(member => {
      const pos = positions[member.id]
      const group = document.createElementNS('http://www.w3.org/2000/svg', 'g')
      group.setAttribute('transform', `translate(${pos.x}, ${pos.y})`)
      group.style.cursor = 'pointer'

      // Circle
      const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle')
      circle.setAttribute('r', member.radius)
      circle.setAttribute('fill', member.is_parent ? '#4F46E5' : '#10B981')
      circle.setAttribute('stroke', '#fff')
      circle.setAttribute('stroke-width', '3')
      group.appendChild(circle)

      // Name text
      const text = document.createElementNS('http://www.w3.org/2000/svg', 'text')
      text.setAttribute('text-anchor', 'middle')
      text.setAttribute('dy', '0.35em')
      text.setAttribute('fill', 'white')
      text.setAttribute('font-size', member.radius > 30 ? '12' : '10')
      text.setAttribute('font-weight', 'bold')
      text.textContent = this.truncateName(member.name, member.radius)
      group.appendChild(text)

      // Tooltip on hover
      group.addEventListener('mouseenter', (e) => {
        this.showTooltip(e, member)
      })
      group.addEventListener('mouseleave', () => {
        this.hideTooltip()
      })

      svg.appendChild(group)
    })
  }

  truncateName(name, radius) {
    const maxChars = Math.floor(radius / 4)
    if (name.length <= maxChars) return name
    return name.substring(0, maxChars - 1) + '.'
  }

  showTooltip(event, member) {
    let tooltip = document.getElementById('graph-tooltip')
    if (!tooltip) {
      tooltip = document.createElement('div')
      tooltip.id = 'graph-tooltip'
      tooltip.className = 'fixed bg-gray-900 text-white text-sm px-3 py-2 rounded shadow-lg z-50 pointer-events-none'
      document.body.appendChild(tooltip)
    }

    const ageText = member.age ? `, Age ${member.age}` : ''
    const roleText = member.role.replace('_', ' ')
    tooltip.innerHTML = `<strong>${member.name}</strong><br>${roleText}${ageText}`
    tooltip.style.display = 'block'
    tooltip.style.left = `${event.pageX + 10}px`
    tooltip.style.top = `${event.pageY + 10}px`
  }

  hideTooltip() {
    const tooltip = document.getElementById('graph-tooltip')
    if (tooltip) {
      tooltip.style.display = 'none'
    }
  }

  openAssessment(relationshipId) {
    const url = `/families/${this.familyIdValue}/relationships/${relationshipId}/assess`
    Turbo.visit(url)
  }
}
