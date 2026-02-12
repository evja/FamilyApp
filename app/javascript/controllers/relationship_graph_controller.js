import { Controller } from "@hotwired/stimulus"
import * as d3 from "d3"

export default class extends Controller {
  static values = {
    url: String,
    familyId: Number
  }

  connect() {
    this.mode = "web"
    this.focusedMemberId = null
    this.simulation = null
    this.svg = null
    this.linkContainer = null
    this.nodeContainer = null
    this.nodes = []
    this.links = []

    this.loadData()
    this.handleResize = this.handleResize.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
    window.addEventListener('resize', this.handleResize)
    document.addEventListener('keydown', this.handleKeydown)
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize)
    document.removeEventListener('keydown', this.handleKeydown)
    if (this.simulation) {
      this.simulation.stop()
    }
    this.removeTooltip()
  }

  handleResize() {
    if (this.nodes.length > 0) {
      this.initGraph()
    }
  }

  handleKeydown(event) {
    if (event.key === 'Escape' && this.mode === 'focus') {
      this.setWebMode()
    }
  }

  async loadData() {
    try {
      const response = await fetch(this.urlValue)
      if (!response.ok) {
        throw new Error(`HTTP error: ${response.status}`)
      }
      const data = await response.json()
      this.processData(data)
      this.initGraph()
    } catch (error) {
      console.error('Failed to load relationship graph data:', error)
      this.element.innerHTML = '<div class="text-center text-red-500">Failed to load relationship map</div>'
    }
  }

  processData(data) {
    // Create node objects with initial positions
    this.nodes = data.members.map(member => ({
      ...member,
      x: this.width / 2,
      y: this.height / 2,
      radius: Math.max(member.radius, 22) // Minimum 44px diameter for touch
    }))

    // Create link objects with source/target references
    this.links = data.relationships.map(rel => ({
      ...rel,
      source: rel.source,
      target: rel.target
    }))
  }

  get width() {
    return this.element.offsetWidth || 600
  }

  get height() {
    return this.element.offsetHeight || 400
  }

  initGraph() {
    // Clear previous content
    this.element.innerHTML = ''

    // Create SVG with D3
    this.svg = d3.select(this.element)
      .append('svg')
      .attr('width', '100%')
      .attr('height', '100%')
      .attr('viewBox', `0 0 ${this.width} ${this.height}`)

    // Add background click handler
    this.svg.append('rect')
      .attr('width', this.width)
      .attr('height', this.height)
      .attr('fill', 'transparent')
      .on('click', () => this.handleBackgroundClick())

    // Create containers for links and nodes (links behind nodes)
    this.linkContainer = this.svg.append('g').attr('class', 'links')
    this.nodeContainer = this.svg.append('g').attr('class', 'nodes')

    // Setup simulation
    this.setupSimulation()

    // Render elements
    this.renderLinks()
    this.renderNodes()
  }

  setupSimulation() {
    if (this.simulation) {
      this.simulation.stop()
    }

    this.simulation = d3.forceSimulation(this.nodes)
      .force('link', d3.forceLink(this.links)
        .id(d => d.id)
        .distance(100))
      .force('charge', d3.forceManyBody().strength(-150))
      .force('center', d3.forceCenter(this.width / 2, this.height / 2))
      .force('collide', d3.forceCollide().radius(d => d.radius + 10))
      .on('tick', () => this.tick())

    // Let simulation settle initially
    this.simulation.alpha(1).restart()
  }

  tick() {
    // Constrain nodes to stay within bounds
    this.nodes.forEach(node => {
      node.x = Math.max(node.radius, Math.min(this.width - node.radius, node.x))
      node.y = Math.max(node.radius, Math.min(this.height - node.radius, node.y))
    })

    // Update link positions
    this.linkContainer.selectAll('line')
      .attr('x1', d => d.source.x)
      .attr('y1', d => d.source.y)
      .attr('x2', d => d.target.x)
      .attr('y2', d => d.target.y)

    // Update node positions
    this.nodeContainer.selectAll('g.node')
      .attr('transform', d => {
        if (this.mode === 'focus' && d.id === this.focusedMemberId) {
          return `translate(${d.x}, ${d.y}) scale(1.2)`
        }
        return `translate(${d.x}, ${d.y})`
      })
  }

  renderLinks() {
    const self = this

    this.linkContainer
      .selectAll('line')
      .data(this.links, d => d.id)
      .join('line')
      .attr('stroke', d => d.health_color)
      .attr('stroke-width', 4)
      .attr('stroke-linecap', 'round')
      .attr('stroke-opacity', d => this.getLinkOpacity(d))
      .style('cursor', 'pointer')
      .style('transition', 'stroke-width 0.2s')
      .on('mouseenter', function() {
        d3.select(this).attr('stroke-width', 6)
      })
      .on('mouseleave', function() {
        d3.select(this).attr('stroke-width', 4)
      })
      .on('click', (event, d) => {
        event.stopPropagation()
        this.openAssessment(d.id)
      })
  }

  renderNodes() {
    const self = this

    const nodeGroups = this.nodeContainer
      .selectAll('g.node')
      .data(this.nodes, d => d.id)
      .join('g')
      .attr('class', 'node')
      .attr('data-id', d => d.id)
      .style('cursor', 'pointer')
      .call(d3.drag()
        .on('start', (event, d) => this.dragStarted(event, d))
        .on('drag', (event, d) => this.dragged(event, d))
        .on('end', (event, d) => this.dragEnded(event, d)))
      .on('click', (event, d) => {
        event.stopPropagation()
        this.handleNodeClick(d)
      })
      .on('mouseenter', (event, d) => this.showTooltip(d, event.pageX, event.pageY))
      .on('mouseleave', () => this.hideTooltip())

    // Circle
    nodeGroups.selectAll('circle')
      .data(d => [d])
      .join('circle')
      .attr('r', d => d.radius)
      .attr('fill', d => d.color)
      .attr('stroke', '#fff')
      .attr('stroke-width', 3)

    // Text (name or emoji)
    nodeGroups.selectAll('text')
      .data(d => [d])
      .join('text')
      .attr('text-anchor', 'middle')
      .attr('dy', '0.35em')
      .attr('fill', 'white')
      .attr('font-size', d => {
        if (d.avatar_emoji) {
          return d.radius > 30 ? '24' : '18'
        }
        return d.radius > 30 ? '12' : '10'
      })
      .attr('font-weight', d => d.avatar_emoji ? 'normal' : 'bold')
      .text(d => {
        if (d.avatar_emoji) {
          return d.avatar_emoji
        }
        return this.truncateName(d.name, d.radius)
      })
  }

  getLinkOpacity(link) {
    if (this.mode === 'web') {
      return link.assessed ? 0.8 : 0.3
    }

    // Focus mode - check if link is connected to focused member
    const sourceId = typeof link.source === 'object' ? link.source.id : link.source
    const targetId = typeof link.target === 'object' ? link.target.id : link.target
    const isConnected = sourceId === this.focusedMemberId || targetId === this.focusedMemberId

    return isConnected ? 1.0 : 0.05
  }

  handleNodeClick(node) {
    if (this.mode === 'focus' && this.focusedMemberId === node.id) {
      // Clicking the same focused node returns to web mode
      this.setWebMode()
    } else {
      // Focus on this node
      this.setFocusMode(node.id)
    }
  }

  handleBackgroundClick() {
    if (this.mode === 'focus') {
      this.setWebMode()
    }
  }

  setWebMode() {
    this.mode = 'web'
    this.focusedMemberId = null

    // Unpin all nodes
    this.nodes.forEach(n => {
      n.fx = null
      n.fy = null
    })

    // Reset forces
    this.simulation
      .force('radial', null)
      .force('charge', d3.forceManyBody().strength(-150))
      .force('center', d3.forceCenter(this.width / 2, this.height / 2))

    // Reheat simulation
    this.simulation.alpha(0.5).restart()

    // Animate link opacity
    this.linkContainer.selectAll('line')
      .transition()
      .duration(400)
      .attr('stroke-opacity', d => this.getLinkOpacity(d))

    // Reset node scales
    this.nodeContainer.selectAll('g.node')
      .transition()
      .duration(400)
      .attr('transform', d => `translate(${d.x}, ${d.y}) scale(1)`)
  }

  setFocusMode(memberId) {
    this.mode = 'focus'
    this.focusedMemberId = memberId

    // Pin focused node to center
    const focusedNode = this.nodes.find(n => n.id === memberId)
    if (focusedNode) {
      focusedNode.fx = this.width / 2
      focusedNode.fy = this.height / 2
    }

    // Unpin others
    this.nodes.forEach(n => {
      if (n.id !== memberId) {
        n.fx = null
        n.fy = null
      }
    })

    // Remove center force, add radial force for ring layout
    this.simulation
      .force('center', null)
      .force('radial', d3.forceRadial(150, this.width / 2, this.height / 2)
        .strength(d => d.id === memberId ? 0 : 0.8))
      .force('charge', d3.forceManyBody().strength(-50))

    // Reheat simulation
    this.simulation.alpha(0.5).restart()

    // Animate link opacity
    this.linkContainer.selectAll('line')
      .transition()
      .duration(400)
      .attr('stroke-opacity', d => this.getLinkOpacity(d))

    // Scale focused node
    this.nodeContainer.selectAll('g.node')
      .transition()
      .duration(400)
      .attr('transform', d => {
        if (d.id === memberId) {
          return `translate(${d.x}, ${d.y}) scale(1.2)`
        }
        return `translate(${d.x}, ${d.y}) scale(1)`
      })
  }

  dragStarted(event, d) {
    if (!event.active) this.simulation.alphaTarget(0.3).restart()
    d.fx = d.x
    d.fy = d.y
  }

  dragged(event, d) {
    d.fx = event.x
    d.fy = event.y
  }

  dragEnded(event, d) {
    if (!event.active) this.simulation.alphaTarget(0)
    // Keep pinned if in focus mode and this is the focused node
    if (!(this.mode === 'focus' && d.id === this.focusedMemberId)) {
      d.fx = null
      d.fy = null
    }
  }

  truncateName(name, radius) {
    const maxChars = Math.floor(radius / 4)
    if (name.length <= maxChars) return name
    return name.substring(0, maxChars - 1) + '.'
  }

  showTooltip(member, x, y) {
    let tooltip = document.getElementById('graph-tooltip')
    if (!tooltip) {
      tooltip = document.createElement('div')
      tooltip.id = 'graph-tooltip'
      tooltip.className = 'fixed bg-gray-900 text-white text-sm px-3 py-2 rounded shadow-lg z-50 pointer-events-none'
      document.body.appendChild(tooltip)
    }

    const ageText = member.age ? `, Age ${member.age}` : ''
    const roleText = member.role.replace('_', ' ')
    const displayName = member.display_name || member.name
    const nameLabel = member.display_name && member.display_name !== member.name
      ? `${displayName} (${member.name})`
      : displayName
    tooltip.innerHTML = `<strong>${nameLabel}</strong><br>${roleText}${ageText}`
    tooltip.style.display = 'block'
    tooltip.style.left = `${x + 10}px`
    tooltip.style.top = `${y + 10}px`
  }

  hideTooltip() {
    const tooltip = document.getElementById('graph-tooltip')
    if (tooltip) {
      tooltip.style.display = 'none'
    }
  }

  removeTooltip() {
    const tooltip = document.getElementById('graph-tooltip')
    if (tooltip) {
      tooltip.remove()
    }
  }

  openAssessment(relationshipId) {
    const url = `/families/${this.familyIdValue}/relationships/${relationshipId}/assess`
    Turbo.visit(url)
  }
}
