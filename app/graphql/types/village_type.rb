models = [Village,Player,Delayed::Job]

models.map do |model|

    model_name = model.to_s.gsub('::','')

    x = GraphQL::ObjectType.define do
        name model_name
        model.fields.map do |field_name,metadata|
            type = field_mapping(types,metadata.options[:type])
            field_name = 'id' if (type == !types.ID)
            Rails.logger.error("Field #{field_name} not found in mapping") if type.nil?
            if !type.nil?
                field field_name, type 
            end
        end
    end
    type_name = "#{model_name}Type"
    Rails.logger.info("Registering type: #{type_name}")
    Types.const_set(type_name, x)
end