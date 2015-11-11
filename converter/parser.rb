module Converter
  class Parser
    ERRORS_FILE_PATH = 'errors.csv'
    OUTPUT_HEADERS = %w(id carrier_code_type carrier_code flight_number)
    ERRORS_HEADERS = %w(id carrier_code flight_number flight_date)

    attr_reader :input_file_path, :output_file_path, :errors

    def initialize(input_file_path: , output_file_path: )
      @input_file_path = input_file_path
      @output_file_path = output_file_path
      @errors = []
    end

    def errors_file_path; ERRORS_FILE_PATH  end

    
    def valid?
      if input_file_path.nil?
        @errors << "<input_file> argument is missing"
        return false
      end

      if output_file_path.nil?
        @errors << "<output_file> argument is missing"
        return false
      end

      unless File.exist?(input_file_path)
        @errors << "Input file does not exists"
        return false
      end     
      true
    end

    def process

      build_file_with_headers(output_file_path, :output)
      build_file_with_headers(errors_file_path, :errors)

      lines = []
      headers_parsed = false
      
      # IO instead of CSV for better performance
      IO.foreach(input_file_path) do |line| 
        lines << line if headers_parsed #Skip headers
        
        if lines.size >= 1000
          process_lines(lines)
          lines = []
        end
        headers_parsed = true
      end
      process_lines(lines)
    end

    private

    def build_file_with_headers(file_path, format)
      CSV.open(file_path, "w") do |csv|
        csv << (format == :output ? OUTPUT_HEADERS : ERRORS_HEADERS)
      end 
    end

    def process_lines(lines)
      lines = CSV.parse(lines.join)
      
      valid_lines, invalid_lines = lines.map { |l| Line.new(*l) }.partition(&:valid?)
      
      add_lines_to_file(lines: valid_lines, file_path: output_file_path, format: :valid)
      add_lines_to_file(lines: invalid_lines, file_path: errors_file_path, format: :invalid)
    end

    def add_lines_to_file(lines:, file_path:, format:)
      CSV.open(file_path, "a") do |csv|
        lines.each do |l| 
          csv << l.to_csv_array(format)
        end
      end
    end
  end
end