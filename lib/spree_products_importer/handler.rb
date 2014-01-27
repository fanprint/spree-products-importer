#encoding: utf-8
require 'roo'
require 'httparty'

module SpreeProductsImporter

  class Handler

    # Receives a file and the get data from each file row
    def self.get_file_data(file)
      spreadsheet   = open_spreadsheet(file)
      header        = spreadsheet.row(1)
      products_list = []
      api_error     = ""
      success       = true

      # Validates each row element
      (2..spreadsheet.last_row).each do |i|
        row            = Hash[[header, spreadsheet.row(i)].transpose]
        # TODO: Falta hacer el metodo validate_product_data
        is_valid, data = validate_product_data row

        if is_valid
          products_list << data
        else
          return data
        end
      end

      # Creates each product with Spree API
      products_list.each do |product_data|
        # Create product
        product = Spree::Product.create product_data[:product]
        # Set product properties
        set_product_properties product, product_data[:properties]
      end

      return success ? "Products created successfully" : "API error #{e}"
    end
      
    # Receives a file and then returns a Roo object acording the file extension
    def self.open_spreadsheet(file)
      case File.extname(file.original_filename)
      when '.csv' then Roo::Csv.new(file.path, nil, :ignore)
      when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
      when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
      else raise "Unknown file type: #{file.original_filename}"
      end
    end

    # Validate each file row according to required attributes
    def self.validate_product_data data
      required_attributes = ["sku", "name", "price"]
      validated_data = {product: {}, properties: {}}

      required_attributes.each do |attr|
        if data[attr].blank?
          return [false, "An error found at line #{i}: #{attr} is required"]
        else
          # Add key => value to normalized and validated hash
          validated_data[:product] = validated_data[:product].merge(attr.to_sym => data[attr])

          # Remove validate element
          data.delete(attr)
        end
      end

      validated_data[:properties] = data
      # TODO: Must define solution to shipping_category_id
      validated_data[:product]    = validated_data[:product].merge(:shipping_category_id => 1)

      [true, validated_data]
    end

    def self.set_product_properties product, properties
      # Add each property to product
      properties.each do |(property_key, property_value)|
        product.set_property(property_key, property_value) unless property_value.blank?
      end
    end

  end

end
