require 'bio'

module FastaAnalyzer
  def self.analyze(file_path)
    entry = Bio::FastaFormat.new(File.read(file_path))
    {
      format: "FASTA",
      accession: entry.entry_id,
      definition: entry.definition,
      length: entry.seq.length
    }
  end
end

