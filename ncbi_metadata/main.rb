require 'net/http'
require 'uri'
require 'nokogiri'
require_relative "ncbi_metadata"

def fetch_file(file_or_url)
  # If it looks like a URL, download it
  if file_or_url =~ URI::DEFAULT_PARSER.make_regexp
    # Convert NCBI nuccore URL to raw XML efetch URL
    if file_or_url.include?("ncbi.nlm.nih.gov/nuccore")
      accession = file_or_url.split("/").last
      file_or_url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=#{accession}&rettype=gb&retmode=xml"
    end

    uri = URI(file_or_url)
    host = uri.host or raise "Invalid URL: missing host"
    port = uri.port or raise "Invalid URL: missing port"
    path = uri.path
    path = "/" if path.nil? || path.empty?

    temp_file = "temp_download.gb"
    puts "Downloading #{file_or_url}..."
    Net::HTTP.start(host, port, use_ssl: true) do |http|
      resp = http.get(path + (uri.query ? "?#{uri.query}" : ""))
      File.write(temp_file, resp.body)
    end
    temp_file
  else
    # Otherwise assume it's a local file
    unless File.exist?(file_or_url)
      raise "File not found: #{file_or_url}"
    end
    file_or_url
  end
end

# Entry point
input = ARGV[0] || raise("Please provide a URL or local file path")
local_file = fetch_file(input)

metadata = NcbiMetadata.extract(local_file)
puts "Metadata extracted:"
puts metadata
