[Village].map do |mongo_class|
    GraphQL::ObjectType.define do
        binding.pry
        name(model_class.name)
        mongo_class.fields.map do |field|
            binding.pry
        end
    end
end