module FormatDetect
  def self.detect(file_path)
    first_line = File.open(file_path, &:readline).strip

    return :genbank if first_line.start_with?("LOCUS")
    return :fasta if first_line.start_with?(">")
    return :xml if first_line.start_with?("<")
    return :gff if first_line =~ /^\w+\t\w+\t\w+/
    return :asn1 if first_line.include?("Bioseq")

    :unknown
  end
end
