import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "fieldCheckbox",
    "yearSelect",
    "courseOption",
    "selectedCourseChips",
    "clearCourses",
    "comparisonCanvas",
    "comparisonTable",
    "courseList",
  ];

  static values = {
    courses: Array,
    fieldLabels: Object,
  };

  connect() {
    console.log("Compare controller connected");
    this.selectedCourses = [];
    this.renderChips();
  }

  // Handle course selection/deselection
  courseChanged(event) {
    const checkbox = event.target;
    const courseId = parseInt(checkbox.value);

    if (checkbox.checked) {
      // Check if we've reached the maximum of 5 courses
      // Rationale being that >5 courses the table becomes too long and complex
      if (this.selectedCourses.length >= 5) {
        checkbox.checked = false;
        alert("You can select a maximum of 5 courses to compare.");
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
    this.updateComparisonView();
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
    this.updateComparisonView();
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
      const courseOption = this.courseOptionTargets.find(
        (opt) => parseInt(opt.value) === courseId
      );
      if (!courseOption) return;

      const courseName = courseOption.dataset.label;

      const pill = document.createElement("span");
      pill.className = "course-pill";
      pill.dataset.courseId = courseId;
      pill.innerHTML = `
        <span class="course-pill-text">${courseName}</span>
        <span class="remove" data-action="click->compare#removeCourse" data-course-id="${courseId}">&times;</span>
      `;
      chipWrap.appendChild(pill);
    });
  }

  // Remove a specific course from the chip
  removeCourse(event) {
    event.stopPropagation();
    const courseId = parseInt(event.target.dataset.courseId);

    // Uncheck the corresponding checkbox
    const checkbox = this.courseOptionTargets.find(
      (opt) => parseInt(opt.value) === courseId
    );
    if (checkbox) {
      checkbox.checked = false;
    }

    this.selectedCourses = this.selectedCourses.filter((id) => id !== courseId);
    this.renderChips();
    this.updateComparisonView();
  }

  // Update the comparison view based on selections
  updateComparisonView() {
    if (this.selectedCourses.length < 2) {
      this.showEmptyState();
      return;
    }

    this.fetchAndRenderComparison();
  }

  // Show empty state when no courses are selected
  showEmptyState() {
    this.comparisonCanvasTarget.innerHTML = `
      <div class="d-flex align-items-center justify-content-center text-muted h-100">
        <div class="text-center">
          <div class="mb-2"><i class="bi bi-columns-gap fs-2"></i></div>
          <div class="fw-semibold">Select at least 2 courses to compare</div>
        </div>
      </div>
    `;
  }

  // Fetch data and render the comparison table
  async fetchAndRenderComparison() {
    const selectedFields = this.fieldCheckboxTargets
      .filter((checkbox) => checkbox.checked)
      .map((checkbox) => checkbox.value);

    const year = parseInt(this.yearSelectTarget.value);

    if (selectedFields.length === 0) {
      this.comparisonCanvasTarget.innerHTML = `
        <div class="d-flex align-items-center justify-content-center text-muted h-100">
          <div class="text-center">
            <div class="mb-2"><i class="bi bi-funnel fs-2"></i></div>
            <div class="fw-semibold">Please select at least one field to display</div>
          </div>
        </div>
      `;
      return;
    }

    // Show loading state
    this.comparisonCanvasTarget.innerHTML = `
      <div class="d-flex align-items-center justify-content-center text-muted h-100">
        <div class="text-center">
          <div class="spinner-border mb-2" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
          <div>Loading comparison data...</div>
        </div>
      </div>
    `;

    try {
      const params = new URLSearchParams({
        course_ids: this.selectedCourses.join(","),
        year: year,
        fields: selectedFields.join(","),
      });

      const response = await fetch(`/compare/data?${params}`);
      const coursesData = await response.json();

      console.log("Courses data received:", coursesData);
      this.renderComparisonTable(coursesData, selectedFields, year);
    } catch (error) {
      console.error("Failed to fetch comparison data:", error);
      this.comparisonCanvasTarget.innerHTML = `
        <div class="d-flex align-items-center justify-content-center text-danger h-100">
          <div class="text-center">
            <div class="mb-2"><i class="bi bi-exclamation-triangle fs-2"></i></div>
            <div class="fw-semibold">Failed to load comparison data</div>
          </div>
        </div>
      `;
    }
  }

  // Render the comparison table
  renderComparisonTable(coursesData, selectedFields, year) {
    let tableHTML = `
      <div class="table-responsive">
        <table class="table table-hover" id="comparison-table">
          <thead class="table-light">
            <tr>
              <th class="metric-header">Metric</th>
    `;

    // Add course headers, get university icons
    coursesData.forEach((course) => {
      const universityLogo =
        course.logo_url || this.getUniversityLogo(course.university);
      tableHTML += `
        <th class="course-header">
          <div class="d-flex align-items-start gap-2">
            <div class="university-logo-container flex-shrink-0">
              <img src="${universityLogo}" alt="${course.university}" class="university-logo">
            </div>
            <div class="flex-grow-1 min-w-0">
              <div class="fw-bold small text-break">${course.degree}</div>
              <small class="text-muted">${course.university}</small>
            </div>
          </div>
        </th>
      `;
    });

    tableHTML += `
            </tr>
          </thead>
          <tbody>
    `;

    // Add rows for each selected field
    selectedFields.forEach((field) => {
      const fieldLabel = this.fieldLabelsValue[field] || field;
      tableHTML += `
        <tr>
          <td class="metric-name fw-semibold">${fieldLabel}</td>
      `;

      coursesData.forEach((course) => {
        const fieldData = course.stats[field];
        const currentValue = this.formatValue(fieldData?.current, field);
        const previousValue = fieldData?.previous;
        const previousYear = fieldData?.previous_year;
        const change = fieldData?.change;

        tableHTML += `<td>`;

        if (currentValue !== "N/A") {
          tableHTML += `<span class="value fs-5 fw-bold">${currentValue}</span>`;

          if (change && previousValue && previousYear) {
            const changeIcon =
              change.direction === "up"
                ? "▲"
                : change.direction === "down"
                ? "▼"
                : "—";
            const changeClass =
              change.direction === "up"
                ? "change-up"
                : change.direction === "down"
                ? "change-down"
                : "change-same";
            const formattedPrevValue = this.formatValue(previousValue, field);

            tableHTML += `
              <span class="${changeClass} ms-2">${changeIcon}</span>
              <div class="previous-value text-muted small mt-1">
                ${formattedPrevValue} (AY${previousYear})
              </div>
            `;
          }
        } else {
          tableHTML += `<span class="text-muted">N/A</span>`;
        }

        tableHTML += `</td>`;
      });

      tableHTML += `</tr>`;
    });

    tableHTML += `
          </tbody>
        </table>
      </div>
    `;

    this.comparisonCanvasTarget.innerHTML = tableHTML;
  }

  // Format values based on field type
  // Display N/A for null values
  formatValue(value, field) {
    if (value === null || value === undefined || value === "") {
      return "N/A";
    }

    const numValue = parseFloat(value);
    if (isNaN(numValue)) {
      return "N/A";
    }

    // Course duration
    if (field === "course_duration") {
      return `${numValue} ${numValue === 1 ? "year" : "years"}`;
    }

    // Add % to Employment rates
    if (field.includes("employment_rate")) {
      return `${numValue.toFixed(1)}%`;
    }

    // Add $ to Salary fields
    if (field.includes("monthly") || field.includes("mthly")) {
      return `$${numValue.toLocaleString(undefined, {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
      })}`;
    }

    return numValue.toFixed(2);
  }

  // Get university logo path
  getUniversityLogo(university) {
    const logoMap = {
      "Nanyang Technological University": "/assets/ntu_logo.png",
      "National University of Singapore": "/assets/nus_logo.png",
      "Singapore Management University": "/assets/smu_logo.jpg",
      "Singapore University of Technology and Design": "/assets/sutd_logo.png",
      "Singapore Institute of Technology": "/assets/sit_logo.jpg",
      "Singapore University of Social Sciences": "/assets/suss_logo.png",
    };

    return logoMap[university] || "/assets/default_university_logo.png";
  }

  // Trigger update when filters change
  filterChanged() {
    if (this.selectedCourses.length >= 2) {
      this.fetchAndRenderComparison();
    }
  }

  // Trigger update when year changes
  yearChanged() {
    if (this.selectedCourses.length >= 2) {
      this.fetchAndRenderComparison();
    }
  }
}
