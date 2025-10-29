import { Application } from "@hotwired/stimulus"

// Start a new Stimulus application
const application = Application.start()

// Turn off debug messages
application.debug = false

// Make it easy to access the Stimulus app in the browser console
window.Stimulus = application

// Export application so other scripts can use the same Stimulus app
export { application }
