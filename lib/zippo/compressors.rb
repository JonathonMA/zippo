Dir[File.join(File.dirname(__FILE__), 'compressor/*.rb')].each do |f|
  require "zippo/compressor/#{File.basename(f, '.rb')}"
end
