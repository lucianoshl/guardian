models = [Village,Player]

models.map do |model|

    x = GraphQL::ObjectType.define do
        name model.to_s
        model.fields.map do |field_name,metadata|
            type = field_mapping(types,metadata.options[:type])
            field_name = 'id' if (type == !types.ID)
            Rails.logger.error("Field #{field_name} not found in mapping") if type.nil?
            if !type.nil?
                field field_name, type 
            end
        end
    end

    Types.const_set("#{model.to_s}Type", x)
end