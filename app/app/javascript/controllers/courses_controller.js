import { Controller } from "@hotwired/stimulus"

// Retrieved from https://stackoverflow.com/a/28339742
function humanize(string) {
	return string
		.replace(/^[\s_]+|[\s_]+$/g, '')
		.replace(/[_\s]+/g, ' ')
		.replace(/^[a-z]/, function(m) { return m.toUpperCase(); });
}

export default class extends Controller {
	connect() {
		const data = document.getElementById("data").dataset;

		const course = JSON.parse(data.course)
		const course_stats = JSON.parse(data.courseStats)

		new Chart(document.getElementById('left-chart'), {
			type: 'line',
			data: {
				labels: course_stats.map((x) => x.year).reverse(),
				datasets: Object.keys(course_stats[0]).filter((property) => !["id", "year", "employment_rate_overall", "employment_rate_ft_perm", "course_id", "created_at", "updated_at"].includes(property)).map((property) => {
					return {
						label: humanize(property),
						data: course_stats.map((x) => x[property]).reverse(),
						borderWidth: 1
					}
				})
			},
			options: {
				scales: {
					y: {
						beginAtZero: true
					}
				}
			}
		});

		new Chart(document.getElementById('right-chart'), {
			type: 'line',
			data: {
				labels: course_stats.map((x) => x.year).reverse(),
				datasets: Object.keys(course_stats[0]).filter((property) => ["employment_rate_overall", "employment_rate_ft_perm"].includes(property)).map((property) => {
					return {
						label: humanize(property),
						data: course_stats.map((x) => x[property]).reverse(),
						borderWidth: 1
					}
				})
			},
			options: {
				scales: {
					y: {
						beginAtZero: false
					}
				}
			}
		});
	}
}
