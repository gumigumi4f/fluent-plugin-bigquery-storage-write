module Fluent
  module BigQuery
    module Storage
      module Helper
        class << self
          def snake_to_pascal(snake_case)
            words = snake_case.split('_')
            words.map(&:capitalize).join
          end

          def get_descriptor_data(file_path)
            File.foreach(file_path) do |line|
              if line.start_with?("descriptor_data = ")
                data = line.chomp.gsub(/^descriptor_data = /, '')
                return eval(data)
              end
            end
          end
        end
      end
    end
  end
end