import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "universitySelect", "schoolSelect", "degreeSelect", "fieldRadio"]
  static values = {
    universitySchools: Object,
    schoolDegrees: Object
  }

  static colors = [
    { bg: 'rgba(100,149,237,0.6)', border: '#6495ed' },
    { bg: 'rgba(255,107,107,0.6)', border: '#ff6b6b' },
    { bg: 'rgba(72,201,176,0.6)', border: '#48c9b0' }
  ]

  connect() {
    console.log("Trends controller connected")
    this.chart = null
    this.programsCache = null
    
    // Load Chart.js dynamically
    this.loadChartJS().then(() => {
      this.initialiseCanvas()
    })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  async loadChartJS() {
    if (window.Chart) {
      return Promise.resolve()
    }
    // TODO: some unit tests to make sure chart.js loads properly
    try {
      const chartModule = await import("chart.js")
      window.Chart = chartModule.Chart
      
      // Register all necessary components
      const { registerables } = await import("chart.js")
      window.Chart.register(...registerables)
    } catch (error) {
      console.error("Failed to load Chart.js:", error)
    }
  }

  initialiseCanvas() {
    const ctx = this.canvasTarget.getContext('2d')
    const parent = this.canvasTarget.parentElement
    
    // Set canvas to full parent size (the container size)
    this.canvasTarget.width = parent.offsetWidth
    this.canvasTarget.height = parent.offsetHeight
    
    // Draw placeholder message
    ctx.fillStyle = '#6c757d'
    ctx.font = '16px Arial'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText(
      'Please select university, school, and degree(s) to view trends',
      this.canvasTarget.width / 2,
      this.canvasTarget.height / 2
    )
  }

  universityChanged() {
    console.log("University changed:", this.universitySelectTarget.value)
    this.updateSchoolOptions()
    this.updateDegreeOptions()
  }

  schoolChanged() {
    console.log("School changed:", this.schoolSelectTarget.value)
    this.updateDegreeOptions()
  }

  fieldChanged() {
    // Only update chart if there's already cached data
    // Not sure how much performance gains this gives, generating charts shouldn't be too intensive
    if (this.programsCache) {
      const field = this.fieldRadioTargets.find(radio => radio.checked)?.value
      const chartData = this.generateChartData(field, this.programsCache)
      this.createChart(chartData, field)
    }
  }

  updateSchoolOptions() {
    const university = this.universitySelectTarget.value
    console.log("update schools for university:", university)
    
    // Reset school and degree selects if the university is changed
    this.schoolSelectTarget.innerHTML = '<option value="">Select a school</option>'
    this.degreeSelectTarget.innerHTML = '<option value="">Select degrees...</option>'
    this.degreeSelectTarget.disabled = true

    if (!university) {
      this.schoolSelectTarget.disabled = true
      return
    }

    this.schoolSelectTarget.disabled = false

    // Get all the schools available
    const schools = this.universitySchoolsValue[university] || []
    const uniqueSchools = [...new Set(schools.map(s => s.school))].sort()

    console.log("Found schools:", uniqueSchools)

    uniqueSchools.forEach(school => {
      const option = document.createElement('option')
      option.value = school
      option.textContent = school
      this.schoolSelectTarget.appendChild(option)
    })
  }

  updateDegreeOptions() {
    const university = this.universitySelectTarget.value
    const school = this.schoolSelectTarget.value

    this.degreeSelectTarget.innerHTML = '<option value="">Select degrees...</option>'
    
    if (!university || !school) {
      this.degreeSelectTarget.disabled = true
      return
    }

    this.degreeSelectTarget.disabled = false

    // Get degrees
    const key = `${university}|${school}`
    const degrees = this.schoolDegreesValue[key] || []
    const uniqueDegrees = [...new Set(degrees.map(d => d.degree))].sort()

    uniqueDegrees.forEach(degree => {
      const option = document.createElement('option')
      option.value = degree
      option.textContent = degree
      this.degreeSelectTarget.appendChild(option)
    })
    
    // Clear previous selection
    this.degreeSelectTarget.selectedIndex = -1
  }

  async updateChart() {
    const field = this.fieldRadioTargets.find(radio => radio.checked)?.value
    const university = this.universitySelectTarget.value
    const school = this.schoolSelectTarget.value
    const selectedDegrees = Array.from(this.degreeSelectTarget.selectedOptions)
      .map(option => option.value)
      .filter(value => value)
      .slice(0, 3)

    if (!university || !school || selectedDegrees.length === 0 || !field) {
      return
    }

    // Fetch data from API at the /trends/data endpoint (see trends_controller.rb)
    const params = new URLSearchParams({
      university,
      school,
      degrees: selectedDegrees.join(','),
      field
    })

    try {
      const response = await fetch(`/trends/data?${params}`)
      const programs = await response.json()
      
      // Cache the programs data
      this.programsCache = programs
      
      const chartData = this.generateChartData(field, programs)
      this.createChart(chartData, field)
    } catch (error) {
      console.error("Failed to fetch trends data:", error)
    }
  }

  generateChartData(field, programs) {
    const selectedDegrees = Array.from(this.degreeSelectTarget.selectedOptions)
      .map(option => option.value)
      .filter(value => value)
      .slice(0, 3)

    if (selectedDegrees.length === 0) {
      return { labels: [], datasets: [] }
    }

    // Generate years from 2013 to 2023
    const years = Array.from({ length: 11 }, (_, i) => (2013 + i).toString())

    const datasets = selectedDegrees.map((degree, idx) => {
      const degreeData = programs.filter(p => p.degree === degree)

      // Create a map of year to value
      const dataByYear = {}
      degreeData.forEach(p => {
        dataByYear[p.year] = parseFloat(p[field]) || 0
      })

      const data = years.map(year => dataByYear[year] ?? null)

      return {
        label: degree,
        data,
        backgroundColor: this.constructor.colors[idx % this.constructor.colors.length].bg,
        borderColor: this.constructor.colors[idx % this.constructor.colors.length].border,
        borderWidth: 2,
        fill: false,
        tension: 0.1,
        spanGaps: true
      }
    })

    return { labels: years, datasets }
  }

  createChart(chartData, field) {
    const ctx = this.canvasTarget.getContext('2d')
    
    // Destroy existing chart if there is one present
    if (this.chart) {
      this.chart.destroy()
    }

    // If no data, show placeholder message
    if (!chartData.labels.length) {
      this.initializeCanvas()
      return
    }

    // Format field name for y-axis label, take from filters
    const fieldRadio = this.fieldRadioTargets.find(radio => radio.checked)
    const yAxisLabel = fieldRadio?.nextElementSibling?.textContent || field.split('_').map(word => 
      word.charAt(0).toUpperCase() + word.slice(1)
    ).join(' ')

    this.chart = new window.Chart(ctx, {
      type: 'line',
      data: chartData,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { 
            display: true, 
            position: 'bottom',
            labels: {
              boxWidth: 12,
              padding: 15
            }
          },
          tooltip: { 
            mode: 'index', 
            intersect: false 
          }
        },
        scales: {
          x: { 
            title: { 
              display: true, 
              text: 'Year' 
            } 
          },
          y: { 
            beginAtZero: true, 
            title: { 
              display: true, 
              text: yAxisLabel 
            } 
          }
        },
        interaction: { 
          mode: 'nearest', 
          axis: 'x', 
          intersect: false 
        }
      }
    })
  }
}
