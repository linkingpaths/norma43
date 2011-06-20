require "iconv"

module Norma43
  
  DATE_FORMAT = '%y%m%d'
  
  def self.read(path_to_file, encoding="iso-8859-1")
    data = Hash.new
    data[:movements] = Array.new
    
    file = File.open(path_to_file, "r") 
    file.each do |encoded_line|
      line = Iconv.iconv("UTF-8", "#{encoding}", encoded_line).to_s
      code = line[0..1]
      data[:info] = self.parse_header(line) if code == '11'
      data[:movements] << self.parse_movement_main(line) if code == '22'
      #TODO support multiple '23' lines (there may be up to 5)
      data[:movements].last.merge!(self.parse_movement_optional(line)) if code == '23'
      #TODO check amount values against those on record 33 
      data[:info].merge!(self.parse_end(line)) if code == '33'
      #TODO parse record 88, end of file
    end 
    file.close

    data
  end
  
  protected

    def self.parse_header(line)
      account = {:bank => line[2..5].to_s, :office => line[6..9].to_s, 
                 :number => line[10..19].to_s, :control => "??"}
      {
        :account => account,
        :begin_date => Date.strptime(line[20..25], DATE_FORMAT), #Date.from_nor43(line[20..25])
        :end_date => Date.strptime(line[26..31], DATE_FORMAT),
        :initial_balance => parse_amount(line[33..46], line[32]),
        :account_owner => line[51..76].strip,
        :currency => line[47..49]          
      }
    end

    def self.parse_movement_main(line)
      {
        :operation_date => Date.strptime(line[10..15], DATE_FORMAT),
        :value_date => Date.strptime(line[16..21], DATE_FORMAT),
        :operation => line[42..51],
        :reference_1 => line[52..63],
        :reference_2 => line[64..79].strip,
        :amount => parse_amount(line[28..41], line[27]),
        :office => line[6..9]
      }
    end

    def self.parse_movement_optional(line)
      {:concept => line[4, 79].strip}
    end

    def self.parse_end(line)
      {:final_balance => parse_amount(line[59..72], line[28])}
    end
    
    def self.parse_amount(value, sign)
      value.to_f / 100 * (sign == 1 ? -1 : 1)
    end
  
end
