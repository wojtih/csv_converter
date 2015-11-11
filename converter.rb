#!/usr/local/bin/ruby -w
require 'csv'

require_relative 'converter/parser'
require_relative 'converter/line'


HELP_MSG = <<-EOF 
Convert: converter <input_file> <output_file>
Help: converter [ --help | -h ]
EOF

if %w(--help -h).include? ARGV[0]
  puts HELP_MSG
elsif ARGV[0][0] == "-"
  puts "Invalid option #{ARGV[0]}"
  puts HELP_MSG
else
  converter = Converter::Parser.new(input_file_path: ARGV[0], output_file_path:ARGV[1])
  if converter.valid?
    converter.process
    puts "Conversion done. Results in #{converter.output_file_path}. Invalid lines in #{converter.errors_file_path}"
  else
    puts converter.errors
    puts HELP_MSG
  end
end