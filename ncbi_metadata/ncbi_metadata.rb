# frozen_string_literal: true
# Load the detector
require_relative "format/format_detect"

# Load all analyzers
require_relative "analyzer/genbank_analyzer"
require_relative "analyzer/fasta_analyzer"
require_relative "analyzer/xml_analyzer"
require_relative "analyzer/gff_analyzer"
require_relative "analyzer/asn1_analyzer"

# Main module that orchestrates detection + analysis
module NcbiMetadata
  def self.extract(file_path)
    case FormatDetect.detect(file_path)
    when :genbank
      GenbankAnalyzer.analyze(file_path)
    when :fasta
      FastaAnalyzer.analyze(file_path)
    when :xml
      XmlAnalyzer.analyze(file_path)
    when :gff
      GffAnalyzer.analyze(file_path)
    when :asn1
      Asn1Analyzer.analyze(file_path)
    else
      raise "Unsupported format: #{file_path}"
    end
  end
end

