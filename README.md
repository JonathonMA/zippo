# Zippo

[![Build Status](https://travis-ci.org/JonathonMA/zippo.svg?branch=master)](https://travis-ci.org/JonathonMA/zippo)

Zippo is a fast zip library for ruby.

A [benchmark](https://gist.github.com/JonathonMA/7943484) is available.

## Installation

Add this line to your application's Gemfile:

    gem 'zippo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zippo

## Usage

It can be called in block form:

    Zippo.open("file.zip") do |zip|
      str = zip["file.txt"]
      other = zip["other/file.txt"]
      puts str
    end

Or without a block:

    zip = Zippo.open("file.zip")
    puts zip["file.txt"]
    zip.close

### Inserting archive members

Files can be inserted into the zip using the
insert method. Note that no data will be written until the
ZipFile is closed:

    zip = Zippo.open("out.zip", "w")
    zip.insert "file1.txt", "path/to/1.txt"
    zip.insert "file2.txt", "path/to/2.txt"
    zip.close

#### By path

    zip.insert "out.txt", "something.txt"

#### Directly from a string buffer

    zip["other.txt"] = "now is the time"

#### By IO

    io = File.open("foo.dat")
    zip.insert "data.dat", io

#### From another zip file (direct stream copy)

Inserting zip data from one file into another allows the
compressed data to be reused from the original zip file
(avoiding uncompression and recompression):

    other = Zippo.open("other.zip")
    zip.insert "final.bin", other["final.bin"]

## TODO

- implement date handling
- implement unix attribute handling

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT License. Copyright (c) 2012-2013 Jonathon M. Abbott
