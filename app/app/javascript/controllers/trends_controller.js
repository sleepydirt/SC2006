import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "canvas", 
    "fieldRadio", 
    "courseOption", 
    "selectedCourseChips", 
    "clearCourses", 
    "courseList"
  ]
  static values = {
    courses: Array
  }

  static colors = [
    { bg: 'rgba(100,149,237,0.6)', border: '#6495ed' },
    { bg: 'rgba(255,107,107,0.6)', border: '#ff6b6b' },
    { bg: 'rgba(72,201,176,0.6)', border: '#48c9b0' },
    { bg: 'rgba(255,193,7,0.6)', border: '#ffc107' },
    { bg: 'rgba(220,53,69,0.6)', border: '#dc3545' }
  ]

  connect() {
    console.log("Trends controller connected")
    this.chart = null
    this.programsCache = null
    this.selectedCourses = []
    
    // Load Chart.js dynamically
    this.loadChartJS().then(() => {
      this.initialiseCanvas()
    })
    
    this.renderChips()
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
      'Please select at least one course to view trends',
      this.canvasTarget.width / 2,
      this.canvasTarget.height / 2
    )
  }

  // Handle course selection/deselection
  courseChanged(event) {
    const checkbox = event.target;
    const courseId = parseInt(checkbox.value);

    if (checkbox.checked) {
      // Check if we've reached the maximum of 5 courses
      if (this.selectedCourses.length >= 5) {
        checkbox.checked = false;
        alert("You can select a maximum of 5 courses for trends analysis.");
        return;
      }
      this.selectedCourses.push(courseId);
    } else {
      this.selectedCourses = this.selectedCourses.filter(
        (id) => id !== courseId
      );
    }

    this.renderChips();
    this.reorderCourseList();
    this.updateChart();
  }

  // Reorder course list: selected courses first, then alphabetical
  reorderCourseList() {
    if (!this.hasCourseListTarget) return;

    const listItems = Array.from(
      this.courseListTarget.querySelectorAll("label[data-course-id]")
    );

    listItems.sort((a, b) => {
      const aId = parseInt(a.dataset.courseId);
      const bId = parseInt(b.dataset.courseId);
      const aSelected = this.selectedCourses.includes(aId);
      const bSelected = this.selectedCourses.includes(bId);

      // Selected items first
      if (aSelected && !bSelected) return -1;
      if (!aSelected && bSelected) return 1;

      // Then sort alphabetically by label
      const aLabel = a.querySelector("input").dataset.label;
      const bLabel = b.querySelector("input").dataset.label;
      return aLabel.localeCompare(bLabel);
    });

    // Reappend in new order
    listItems.forEach((item) => this.courseListTarget.appendChild(item));
  }

  // Clear all selected courses
  clearAllCourses() {
    this.courseOptionTargets.forEach((checkbox) => {
      checkbox.checked = false;
    });
    this.selectedCourses = [];
    this.renderChips();
    this.updateChart();
  }

  // Render course chips in the dropdown button
  renderChips() {
    const chipWrap = this.selectedCourseChipsTarget;
    chipWrap.innerHTML = "";

    if (this.selectedCourses.length === 0) {
      const placeholder = document.createElement("span");
      placeholder.className = "text-muted";
      placeholder.textContent = "Select courses";
      chipWrap.appendChild(placeholder);
      return;
    }

    this.selectedCourses.forEach((courseId) => {
      const course = this.coursesValue.find((c) => c.id === courseId);
      if (!course) return;

      const chip = document.createElement("div");
      chip.className = "course-pill";
      chip.innerHTML = `
        <span class="course-pill-text">${course.display_name}</span>
        <span class="remove" data-course-id="${courseId}">&times;</span>
      `;

      // Add click handler for remove button
      chip.querySelector(".remove").addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();
        this.removeCourse(courseId);
      });

      chipWrap.appendChild(chip);
    });
  }

  // Remove a course from selection
  removeCourse(courseId) {
    // Uncheck the checkbox
    const checkbox = this.courseOptionTargets.find(
      (cb) => parseInt(cb.value) === courseId
    );
    if (checkbox) checkbox.checked = false;

    // Remove from selected array
    this.selectedCourses = this.selectedCourses.filter((id) => id !== courseId);

    this.renderChips();
    this.reorderCourseList();
    this.updateChart();
  }

  fieldChanged() {
    // Update chart when field selection changes
    this.updateChart();
  }

  async updateChart() {
    const field = this.fieldRadioTargets.find(radio => radio.checked)?.value

    if (this.selectedCourses.length === 0 || !field) {
      this.initialiseCanvas();
      return;
    }

    // Fetch data from API at the /trends/data endpoint
    const params = new URLSearchParams({
      course_ids: this.selectedCourses.join(','),
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
      this.initialiseCanvas();
    }
  }

  generateChartData(field, programs) {
    if (this.selectedCourses.length === 0) {
      return { labels: [], datasets: [] }
    }

    // Generate years from 2013 to 2023
    const years = Array.from({ length: 11 }, (_, i) => (2013 + i).toString())

    const datasets = this.selectedCourses.map((courseId, idx) => {
      const courseData = programs.filter(p => p.course_id === courseId)
      const course = this.coursesValue.find(c => c.id === courseId)

      // Create a map of year to value
      const dataByYear = {}
      courseData.forEach(p => {
        dataByYear[p.year] = parseFloat(p[field]) || 0
      })

      const data = years.map(year => dataByYear[year] ?? null)

      return {
        label: course ? course.degree : `Course ${courseId}`,
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
      this.initialiseCanvas()
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
