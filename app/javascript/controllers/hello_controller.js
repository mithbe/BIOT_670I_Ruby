import { Controller } from "@hotwired/stimulus"

// A simple Stimulus controller
export default class extends Controller {
    // This runs automatically when the controller is connected to the page
    connect() {
        // "Hello World!" inside the element this controller is attached to
        this.element.textContent = "Hello World!"
    }
}

