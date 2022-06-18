require 'csv'

class DataTransformService
  
  # ==== This method does:
  #
  #  Iterates over the csv and transforms it into JSON documents
  #
  # ==== With params:
  #
  # @param file_path <String> - Path to the csv file to process
  #
  # ==== And returns:
  #
  # @return total_records_processed
  #
  # ==== And is used like:
  #
  # service.transform(csv_path)
  #
  def transform(file_path)
    Rails.logger.info("Processing file from location: [#{file_path}]")
    row_counter = 0
    parsed_data = []
    
    CSV.open(file_path, 'r:UTF-8', headers: true) do |csv|
      csv.each do |csv_row|
        row_data = {}
        images = {}
        attributes = {}


        csv_row.each_with_index do |csv_cell, column|
          if is_in_image_range(column) then
            images[csv_cell[0]] = csv_cell[1]
          elsif is_in_attributes_range(column) then
            attributes[csv_cell[0]] = csv_cell[1]
          else
            row_data[csv_cell[0]] = csv_cell[1]
          end
        end

        row_data["images"] = images
        row_data["attributes"] = attributes
        parsed_data[row_counter] = row_data
        row_counter += 1
      end
    end

    write_to_file(parsed_data)
    return row_counter
  end

  # ==== This method does:
  #
  #  Writes an object to a file, serialized as JSON
  #
  # ==== With params:
  #
  # @param object <object> - Object to be written to file as json
  # @param path <String> - Output file path. Default value: "out.json"
  #
  # ==== And returns:
  #
  # @return void
  #
  # ==== And is used like:
  #
  # write_to_file(object) 
  # write_to_file(object, "path")
  #
  def write_to_file(object, path = "out.json")
    json = JSON.pretty_generate(object)
    out_file = File.new(path, "w")
    out_file.puts(json)
    out_file.close
  end

  # ==== This method does:
  #
  #  Given a column ordinal, this function returns whether or not it belongs in the images subcategory
  #
  # ==== With params:
  #
  # @param column_ordinal_index <integer> - Ordinal index that is checked
  #
  # ==== And returns:
  #
  # @return True if the index belongs in the images subcategory, false if it doesn't
  #
  # ==== And is used like:
  #
  # is_in_image_range(column_rodinal)
  #
  def is_in_image_range(column_ordinal_index)
    return (8..11) === column_ordinal_index
  end

  # ==== This method does:
  #
  #  Given a column ordinal, this function returns whether or not it belongs in the attributes subcategory
  #
  # ==== With params:
  #
  # @param column_ordinal_index <integer> - Ordinal index that is checked
  #
  # ==== And returns:
  #
  # @return True if the index belongs in the attributes subcategory, false if it doesn't
  #
  # ==== And is used like:
  #
  # is_in_attributes_range(column_rodinal)
  #
  def is_in_attributes_range(column_ordinal_index)
    return (12..31) === column_ordinal_index
  end

end