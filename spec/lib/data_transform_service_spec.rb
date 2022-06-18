require 'rails_helper'

RSpec.describe DataTransformService do

  let!(:csv_path) { 'spec/csv/sample-part-data.csv'}
  let!(:json_path) { 'out.json'}
  let!(:service) { DataTransformService.new}
  
  describe '#transform' do
  
    it 'Should return number of processed rows' do
      result = service.transform(csv_path)
      expect(result).to eql(25)
    end

    it 'should transform rows in the passed file from csv to JSON docs' do
      result = service.transform(csv_path)
      file = File.open(json_path)
      file_data = file.read
      object = JSON.parse(file_data)
      expect(object.length()).to eql(25)
      file.close()
    end


    it 'should parse first row' do
      result = service.transform(csv_path)
      file = File.open(json_path)
      file_data = file.read
      file.close()
      object = JSON.parse(file_data)
      first_row = object[0]
      expect(first_row["sku"]).to eql("10061122131120HLF")

    end

    it 'should parse last row' do
      result = service.transform(csv_path)
      file = File.open(json_path)
      file_data = file.read
      file.close()
      object = JSON.parse(file_data)
      last_row = object[object.length-1]
      expect(last_row["sku"]).to eql("10064555332110ELF")
    end

    it 'should parse images sub-category' do
      result = service.transform(csv_path)
      file = File.open(json_path)
      file_data = file.read
      file.close()
      object = JSON.parse(file_data)
      first_row = object[0]
      expect(first_row["images"]["image"]).to eql("http://www.amphenol-icc.com/media/wysiwyg/files/pn-image/yll_d 10061122.jpg")
      expect(first_row["images"]["3d_model_iges"]).to eql("https://cdn.amphenol-icc.com/media/wysiwyg/files/3d/i10061122-131120hlf.zip")

    end

    it 'should parse attributes sub-category' do 
      result = service.transform(csv_path)
      file = File.open(json_path)
      file_data = file.read
      file.close()
      object = JSON.parse(file_data)
      first_row = object[0]
      last_row = object[object.length-1]
      expect(first_row["attributes"]["eu_rohs_y"]).to eql("Yes")
      expect(first_row["attributes"]["voltage_rating"]).to eql("30V")
      expect(last_row["termination_style_filter"]).to eql(nil)
    end
  end


  describe '#is_in_image_range' do
    it 'Returns true for columns that describe the images sub-category' do
      expect(service.is_in_image_range(8)).to eql(true)
      expect(service.is_in_image_range(9)).to eql(true)
      expect(service.is_in_image_range(10)).to eql(true)
      expect(service.is_in_image_range(11)).to eql(true)
    end

    it 'Returns false for columns that describe the images sub-category' do
      expect(service.is_in_image_range(-1)).to eql(false)
      expect(service.is_in_image_range(0)).to eql(false)
      expect(service.is_in_image_range(7)).to eql(false)
      expect(service.is_in_image_range(12)).to eql(false)
    end
  end


  describe '#is_in_attributes_range' do
    it 'Returns true for columns that describe the attributes sub-category' do
      expect(service.is_in_attributes_range(12)).to eql(true)
      expect(service.is_in_attributes_range(20)).to eql(true)
      expect(service.is_in_attributes_range(30)).to eql(true)
      expect(service.is_in_attributes_range(31)).to eql(true)
    end

    it 'Returns false for columns that describe the attributes sub-category' do
      expect(service.is_in_attributes_range(-1)).to eql(false)
      expect(service.is_in_attributes_range(8)).to eql(false)
      expect(service.is_in_attributes_range(11)).to eql(false)
      expect(service.is_in_attributes_range(32)).to eql(false)
    end
  end
  

  describe '#write_to_file' do
    it 'Writes object as valid JSON' do
      object = { }
      object["key"] = "value"
      service.write_to_file(object, "test.json")
      file = File.open("test.json")
      file_data = file.read()
      file.close()

      parsed_object = JSON.parse(file_data)

      expect(parsed_object["key"]).to eql(object["key"])

      File.delete("test.json")
    end
  end
end