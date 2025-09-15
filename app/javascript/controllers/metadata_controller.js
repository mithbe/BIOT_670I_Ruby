import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["genetic", "image", "spreadsheet"]

    toggle(event) {
        const fileType = event.target.value

        this.geneticTarget.hidden = fileType !== "genetic"
        this.imageTarget.hidden = fileType !== "image"
        this.spreadsheetTarget.hidden = fileType !== "spreadsheet"
    }
}