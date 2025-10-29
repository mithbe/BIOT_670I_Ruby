// Bring in the main Stimulus application
import { application } from "controllers/application"

// Helper to automatically load all controllers in the controllers/ folder
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// Find and register all controllers that match *_controller.js in the controllers folder
eagerLoadControllersFrom("controllers", application)
