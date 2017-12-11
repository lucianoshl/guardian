Types::QueryType = GraphQL::ObjectType.define do
  name "Query"
  # Add root-level fields here.
  # They will be entry points for queries on your schema.

  field :villages, types[Types::VillageType] do
    argument :id, types.String
    argument :name, types.String
    resolve ->(obj, args, ctx) {
      
      Village.where(args.to_h).limit(10)
    }
  end

  field :tasks, types[Types::DelayedBackendMongoidJobType] do
    argument :id, types.String
    resolve ->(obj, args, ctx) {
      Delayed::Job.asc(:run_at).where(args.to_h)
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
