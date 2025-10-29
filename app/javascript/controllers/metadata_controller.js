import { Controller } from "@hotwired/stimulus"

// Handles the Single vs Bulk upload panes and showing/hiding columns in the bulk table
export default class extends Controller {
    // These are the elements we care about in the HTML
    static targets = [
        "singlePane", "bulkPane",
        "tabSingleBtn", "tabBulkBtn"
    ]

    connect() {
        // When the page loads, show the Single upload pane by default
        if (this.singlePaneTarget && this.bulkPaneTarget) {
            this.showSingle()
        }

        // Go through the bulk table and hide columns that don’t apply to each row
        this.applyTypeColumnVisibility()
    }

    // Show the Single pane and make its tab look active
    showSingle() {
        if (!this.singlePaneTarget || !this.bulkPaneTarget) return
        this.singlePaneTarget.hidden = false
        this.bulkPaneTarget.hidden = true
        this.highlightTab(this.tabSingleBtnTarget, this.tabBulkBtnTarget)
    }

    // Show the Bulk pane and highlight the right tab
    showBulk() {
        if (!this.singlePaneTarget || !this.bulkPaneTarget) return
        this.singlePaneTarget.hidden = true
        this.bulkPaneTarget.hidden = false
        this.highlightTab(this.tabBulkBtnTarget, this.tabSingleBtnTarget)

        // Make sure only relevant columns are visible for each row
        this.applyTypeColumnVisibility()
    }

    // Simple helper to make the active tab bold and the inactive one normal
    highlightTab(activeBtn, inactiveBtn) {
        if (activeBtn)  activeBtn.style.fontWeight = "bold"
        if (inactiveBtn) inactiveBtn.style.fontWeight = "normal"
    }

    // Hide columns that don’t match the file type of each row in the bulk table
    applyTypeColumnVisibility() {
        const bulkPane = this.bulkPaneTarget
        if (!bulkPane) return

        const rows = bulkPane.querySelectorAll("tbody tr[data-filetype]")
        rows.forEach(row => {
            const fileType = row.getAttribute("data-filetype") || ""
            const ext      = (row.getAttribute("data-extension") || "").toLowerCase()

            // Hide everything first
            row.querySelectorAll("[data-typecol]").forEach(cell => {
                cell.hidden = true
            })

            // Figure out which columns to show based on file extension
            const showKeys = []
            if (["jpg", "jpeg"].includes(ext)) showKeys.push("jpg")
            if (["png"].includes(ext))         showKeys.push("png")
            if (["csv"].includes(ext))         showKeys.push("csv")
            if (["tsv"].includes(ext))         showKeys.push("tsv")
            if (["xlsx"].includes(ext))        showKeys.push("xlsx")
            if (["fasta","fa"].includes(ext))  showKeys.push("fasta")
            if (["fastq","fq"].includes(ext))  showKeys.push("fastq")
            if (["gb","gbk"].includes(ext))    showKeys.push("gb", "gbk", "genbank")
            if (["xml"].includes(ext))         showKeys.push("xml")
            if (["pdf"].includes(ext))         showKeys.push("pdf")

            // If we didn’t match any extension, fall back to the general file type
            if (showKeys.length === 0) {
                if (fileType === "image")          showKeys.push("jpg", "png")
                else if (fileType === "spreadsheet") showKeys.push("csv", "tsv", "xlsx")
                else if (fileType === "genetic")     showKeys.push("fasta", "fastq", "genbank")
                else                                 showKeys.push("other")
            }

            // Unhide all the columns that should be visible
            showKeys.forEach(key => {
                row.querySelectorAll(`[data-typecol*="${key}"]`).forEach(cell => {
                    cell.hidden = false
                })
            })
        })
    }
}
