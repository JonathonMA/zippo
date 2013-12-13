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
          Zippo.open("out.zip") do |f|
            f['file.ext'].crc32.should eq 0x8c736521
            f['file.ext'].compressed_size.should eq 5
            f['file.ext'].uncompressed_size.should eq 3
            f['file.ext'].read.should eq "foo"
          end
        end
      end
      it "should perform direct zip copying" do
        in_working_directory do
          zip = Zippo.open(test_file "test.zip")
          Zippo.open("out.zip", "w") do |out|
            out.directory.insert 'out.file', zip['test.file']
          end
          zip.close

          IO.write "/tmp/out.zip", IO.read("out.zip")

          Zippo.open("out.zip") { |v| v['out.file'].read }.should eq "The quick brown fox jumps over the lazy dog.\n"
        end
      end
      pending "should be able to peform direct zip copying after the source zip is closed"
      pending "should be configurable in terms of compression method and effort"
    end
  end
end
