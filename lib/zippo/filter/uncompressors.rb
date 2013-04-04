Dir[File.join(File.dirname(__FILE__), 'uncompressor/*.rb')].each do |f|
  require "zippo/filter/uncompressor/#{File.basename(f, '.rb')}"
end
