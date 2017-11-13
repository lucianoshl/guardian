Types::QueryType = GraphQL::ObjectType.define do
  name "Query"
  # Add root-level fields here.
  # They will be entry points for queries on your schema.

  field :village, Types::VillageType do
    description "An example field added by the generator"
    # argument :id, !types.String
    argument :name, !types.String
    resolve ->(obj, args, ctx) {
      Village.where(args.to_h).first
    }
  end

  # TODO: remove me
  field :testField, types.String do
    description "An example field added by the generator"
    resolve ->(obj, args, ctx) {
      "Hello World!"
    }
  end
end
