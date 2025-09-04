# frozen_string_literal: true
module Asn1Analyzer
  def self.analyze(file_path)
    {
      format: "ASN.1",
      note: "Direct parsing not supported. Use NCBI tools (asn2xml/asn2gb) to convert before analysis.",
      original_file: file_path
    }
  end
end

