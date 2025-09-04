module GffAnalyzer
  def self.analyze(file_path)
    features = []

    File.foreach(file_path) do |line|
      next if line.start_with?("#") || line.strip.empty?

      seqid, source, type, start, stop, score, strand, phase, attributes = line.split("\t")
      features << {
        seqid: seqid,
        source: source,
        type: type,
        start: start.to_i,
        stop: stop.to_i,
        strand: strand,
        attributes: attributes
      }
    end

    {
      format: "GFF",
      feature_count: features.size,
      features: features
    }
  end
end
