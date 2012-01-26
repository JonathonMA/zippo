Dir[File.join(File.dirname(__FILE__), 'uncompressor/*.rb')].each do |f|
  require "zippo/uncompressor/#{File.basename(f, '.rb')}"
end
