require 'nokogiri'

module XmlAnalyzer
  def self.analyze(file_path)
    doc = Nokogiri::XML(File.read(file_path))
    seq = doc.at_xpath("//GBSeq") || doc.at_xpath("//INSDSeq")

    unless seq
      raise "No sequence found in XML: #{file_path}"
    end

    {
      format: "XML",
      accession: seq.at_xpath("GBSeq_locus")&.text || seq.at_xpath("INSDSeq_accession-version")&.text,
      definition: seq.at_xpath("GBSeq_definition")&.text || seq.at_xpath("INSDSeq_definition")&.text,
      organism: seq.at_xpath("GBSeq_organism")&.text || seq.at_xpath("INSDSeq_organism")&.text,
      length: (seq.at_xpath("GBSeq_length")&.text || seq.at_xpath("INSDSeq_length")&.text)&.to_i,
      molecule_type: seq.at_xpath("GBSeq_moltype")&.text || seq.at_xpath("INSDSeq_moltype")&.text,
      taxonomy: seq.at_xpath("GBSeq_taxonomy")&.text || seq.at_xpath("INSDSeq_taxonomy")&.text,
      features: (seq.xpath("GBSeq_feature-table/GBFeature/GBFeature_key") + seq.xpath("INSDSeq_feature-table/INSDFeature/INSDFeature_key")).map(&:text).uniq
    }
  end
end
