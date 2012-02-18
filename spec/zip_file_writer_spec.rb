require "spec_helper"

require "zippo" #
require "zippo/zip_file_writer"
require "zippo/zip_directory"

module Zippo
  describe ZipFileWriter do
    describe ".write" do
      it "should write the zip file" do
        in_working_directory do
          directory = ZipDirectory.new
          directory["file.ext"] = "foo"
          writer = ZipFileWriter.new directory, "out.zip"
          writer.write
          File.open("/home/jma/yay.zip","w") {|f| f.write File.read("out.zip") }
          Zippo.open("out.zip") do |f|
            f['file.ext'].crc32.should eq 0x8c736521
            f['file.ext'].compressed_size.should eq 5
            f['file.ext'].uncompressed_size.should eq 3
            f['file.ext'].read.should eq "foo"
          end
        end
      end
    end
  end
end
