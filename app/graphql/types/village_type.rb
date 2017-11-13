models = [Village,Player]

models.map do |model|
    model = Village
    def field_mapping(types,mongo_type)
        field_mapping = {}
        field_mapping[BSON::ObjectId] = !types.ID
        field_mapping[Integer] = !types.Int
        field_mapping[String] = !types.String
        field_mapping[mongo_type]
    end

    x = GraphQL::ObjectType.define do
        name model.to_s
        model.fields.map do |field_name,metadata|
            type = field_mapping(types,metadata.options[:type])
            # binding.pry if type.nil?
            field_name = 'id' if (type == !types.ID)

            Rails.logger.error("Field #{field_name} not found in mapping".white.on_red) if type.nil?
            if !type.nil?
                field field_name, type 
                # argument field_name, type
            end
        end
        # field :id, !types.ID
        # field :name, !types.String
    end

    Types.const_set("#{model.to_s}Type", x)
end