import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "salaryMinRange", "salaryMaxRange",
    "salaryMinInput", "salaryMaxInput",
    "salaryMinDisplay", "salaryMaxDisplay",
    "salaryTrack",
    "employmentMinRange", "employmentMaxRange",
    "employmentMinInput", "employmentMaxInput",
    "employmentMinDisplay", "employmentMaxDisplay",
    "employmentTrack"
  ]

  connect() {
    this.initialiseSalarySliders()
    this.initialiseEmploymentSliders()
  }

  initialiseSalarySliders() {
    this.updateSalaryRange()
    this.updateSalaryTrack()
  }

  initialiseEmploymentSliders() {
    this.updateEmploymentRange()
    this.updateEmploymentTrack()
  }

  updateSalaryRange() {
    let minVal = parseInt(this.salaryMinRangeTarget.value) || 0
    let maxVal = parseInt(this.salaryMaxRangeTarget.value) || 10000

    // Prevent thumbs from crossing
    if (minVal > maxVal - 100) {
      minVal = maxVal - 100
      this.salaryMinRangeTarget.value = minVal
    }

    // Update hidden inputs and display
    this.salaryMinInputTarget.value = minVal
    this.salaryMaxInputTarget.value = maxVal
    this.salaryMinDisplayTarget.textContent = minVal.toLocaleString()
    this.salaryMaxDisplayTarget.textContent = maxVal.toLocaleString()
    
    // Update visual track
    this.updateSalaryTrack()
  }

  updateSalaryMax() {
    let minVal = parseInt(this.salaryMinRangeTarget.value) || 0
    let maxVal = parseInt(this.salaryMaxRangeTarget.value) || 10000

    // Prevent thumbs from crossing
    if (maxVal < minVal + 100) {
      maxVal = minVal + 100
      this.salaryMaxRangeTarget.value = maxVal
    }

    this.updateSalaryRange()
  }

  updateSalaryTrack() {
    const min = parseInt(this.salaryMinRangeTarget.value) || 0
    const max = parseInt(this.salaryMaxRangeTarget.value) || 10000
    const minPercent = (min / 10000) * 100
    const maxPercent = (max / 10000) * 100
    
    this.salaryTrackTarget.style.left = `${minPercent}%`
    this.salaryTrackTarget.style.width = `${maxPercent - minPercent}%`
  }

  updateEmploymentRange() {
    let minVal = parseInt(this.employmentMinRangeTarget.value) || 0
    let maxVal = parseInt(this.employmentMaxRangeTarget.value) || 100

    // Prevent thumbs from crossing
    if (minVal > maxVal - 1) {
      minVal = maxVal - 1
      this.employmentMinRangeTarget.value = minVal
    }

    // Update hidden inputs and display
    this.employmentMinInputTarget.value = minVal
    this.employmentMaxInputTarget.value = maxVal
    this.employmentMinDisplayTarget.textContent = minVal
    this.employmentMaxDisplayTarget.textContent = maxVal
    
    // Update visual track
    this.updateEmploymentTrack()
  }

  updateEmploymentMax() {
    let minVal = parseInt(this.employmentMinRangeTarget.value) || 0
    let maxVal = parseInt(this.employmentMaxRangeTarget.value) || 100

    // Prevent thumbs from crossing
    if (maxVal < minVal + 1) {
      maxVal = minVal + 1
      this.employmentMaxRangeTarget.value = maxVal
    }

    this.updateEmploymentRange()
  }

  updateEmploymentTrack() {
    const min = parseInt(this.employmentMinRangeTarget.value) || 0
    const max = parseInt(this.employmentMaxRangeTarget.value) || 100
    const minPercent = (min / 100) * 100
    const maxPercent = (max / 100) * 100
    
    this.employmentTrackTarget.style.left = `${minPercent}%`
    this.employmentTrackTarget.style.width = `${maxPercent - minPercent}%`
  }
}
