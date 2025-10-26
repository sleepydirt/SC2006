import { Controller } from "@hotwired/stimulus"

// data-controller="profile-edit"
export default class extends Controller {
  static targets = ["form", "editButton", "saveButton", "cancelButton"]

  connect() {
    console.log("profile_edit_controller connected")
  }

  edit() {
    console.log("user clicked edit button")
    document.body.classList.add('editing')
    this.editButtonTarget.style.display = 'none'
    this.saveButtonTarget.style.display = 'inline-block'
    this.cancelButtonTarget.style.display = 'inline-block'
  }

  cancel() {
    console.log("user clicked cancel button")
    document.body.classList.remove('editing')
    this.editButtonTarget.style.display = 'inline-block'
    this.saveButtonTarget.style.display = 'none'
    this.cancelButtonTarget.style.display = 'none'
    // reset form to original values
    this.formTarget.reset()
  }
}
