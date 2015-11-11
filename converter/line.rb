module Converter
  class Line
    attr_reader :id, :carrier_code, :flight_number, :flight_date

    def initialize(id = nil, carrier_code = nil, flight_number = nil, flight_date = nil)
      @id = id
      @carrier_code = carrier_code
      @flight_number = flight_number
      @flight_date = flight_date      
    end

    def valid?
      return false if id.nil? || id.empty?
      return false if carrier_code.nil? || ![2, 3].include?(carrier_code.length)
      return false if flight_number.nil? || flight_number.empty?
      return false if flight_date.nil?
      Date.iso8601(flight_date) rescue(false)
    end

    def carrier_code_type
      if carrier_code.length == 2 || carrier_code[2] == "*"
        "IATA"
      else
        "ICAO"
      end
    end

    def to_csv_array(format)
      if format == :valid
        [ id, carrier_code_type, carrier_code, flight_date ]
      else
        [ id, carrier_code, flight_number, flight_date ]
      end
    end
  end
end