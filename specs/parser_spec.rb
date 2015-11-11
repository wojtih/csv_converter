require 'rspec'
require 'csv'

require_relative './../converter/parser'
require_relative './../converter/line'

describe Converter::Parser do
  describe "validation" do
    it "requires input_file_path attribute" do
      parser = Converter::Parser.new(input_file_path: nil, output_file_path: "Foo")
      parser.valid?
      expect(parser.errors).to include("<input_file> argument is missing")
    end

    it "requires input_file_path to exists" do
      expect(File).to receive(:exist?).and_return(false)
      parser = Converter::Parser.new(input_file_path: "Bar", output_file_path: "Foo")
      parser.valid?
      expect(parser.errors).to include("Input file does not exists")
    end

    it "requires output_file_path attribute" do
      parser = Converter::Parser.new(input_file_path: "Foo", output_file_path: nil)
      parser.valid?
      expect(parser.errors).to include("<output_file> argument is missing")
    end
  end

  describe "errors_file_path" do
    it "returns path to errors file" do
      parser = Converter::Parser.new(input_file_path: "foo", output_file_path: "bar")
      expect(parser.errors_file_path).to eq "errors.csv"
    end
  end

  describe "process" do
    let(:parser) { Converter::Parser.new(input_file_path: "specs/test_data/input.csv", 
        output_file_path: "specs/test_data/output.csv") }
    
    before { allow(parser).to receive(:errors_file_path).and_return("specs/test_data/errors.csv") }

    after do
      File.delete("specs/test_data/errors.csv")
      File.delete("specs/test_data/output.csv")
    end
    
    it "puts valid rows to output file" do
      
      parser.process

      results = File.read("specs/test_data/output.csv")
      
      expect(results).to include("id,carrier_code_type,carrier_code,flight_number")
      expect(results).to include("10003906-0-0-0,IATA,SK,2012-12-13")
    end

    it "puts invalid rows to errors file" do
      
      parser.process

      errors = File.read("specs/test_data/errors.csv")
      
      expect(errors).to include("id,carrier_code,flight_number,flight_date")
      expect(errors).to include("10009266-0-0-0,TG,7165,2013-01-66")
      expect(errors).to include("10009266-0-0-0,TGTG,7165,2013-01-2")
      expect(errors).to include("10009266-0-0-0,,,")
    end
  end
end