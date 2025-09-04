require 'bio'

module GenbankAnalyzer
  def self.analyze(file_path)
    entry = Bio::GenBank.new(File.read(file_path))
    {
      format: "GenBank",
      accession: entry.accession,
      definition: entry.definition,
      organism: entry.organism,
      length: entry.seq.length
    }
  end
end

