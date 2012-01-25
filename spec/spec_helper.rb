def io_for(filename)
  File.open test_file(filename), "rb:ASCII-8BIT"
end
def test_file(filename)
  File.join(File.join(File.dirname(__FILE__), 'data'), filename)
end
