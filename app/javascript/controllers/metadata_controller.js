import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "singlePane", "bulkPane",
        "tabSingleBtn", "tabBulkBtn"
    ]

    connect() {
        // Default to showing Single on first load
        if (this.singlePaneTarget && this.bulkPaneTarget) {
            this.showSingle()
        }

        // When bulk table is present, prune columns per row
        this.applyTypeColumnVisibility()
    }

    showSingle() {
        if (!this.singlePaneTarget || !this.bulkPaneTarget) return
        this.singlePaneTarget.hidden = false
        this.bulkPaneTarget.hidden = true
        this.highlightTab(this.tabSingleBtnTarget, this.tabBulkBtnTarget)
    }

    showBulk() {
        if (!this.singlePaneTarget || !this.bulkPaneTarget) return
        this.singlePaneTarget.hidden = true
        this.bulkPaneTarget.hidden = false
        this.highlightTab(this.tabBulkBtnTarget, this.tabSingleBtnTarget)
        this.applyTypeColumnVisibility()
    }

    highlightTab(activeBtn, inactiveBtn) {
        if (activeBtn)  activeBtn.style.fontWeight = "bold"
        if (inactiveBtn) inactiveBtn.style.fontWeight = "normal"
    }

    // Hide per-type placeholder columns that don't match the row's file type/ext
    applyTypeColumnVisibility() {
        const bulkPane = this.bulkPaneTarget
        if (!bulkPane) return

        const rows = bulkPane.querySelectorAll("tbody tr[data-filetype]")
        rows.forEach(row => {
            const fileType = row.getAttribute("data-filetype") || ""
            const ext      = (row.getAttribute("data-extension") || "").toLowerCase()

            // Hide all type columns initially
            row.querySelectorAll("[data-typecol]").forEach(cell => {
                cell.hidden = true
            })

            // Decide which one(s) to show
            // ext is more specific; fallback to type
            const showKeys = []

            // Map ext -> keys
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

            // If nothing specific matched by ext, fall back by broad fileType
            if (showKeys.length === 0) {
                if (fileType === "image")      showKeys.push("jpg", "png")
                else if (fileType === "spreadsheet") showKeys.push("csv", "tsv", "xlsx")
                else if (fileType === "genetic")     showKeys.push("fasta", "fastq", "genbank")
                else                                showKeys.push("other")
            }

            // Unhide matching cells whose data-typecol contains any of the keys
            showKeys.forEach(key => {
                row.querySelectorAll(`[data-typecol*="${key}"]`).forEach(cell => {
                    cell.hidden = false
                })
            })
        })
    }
}