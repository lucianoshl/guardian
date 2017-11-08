Types::TaskType = GraphQL::ObjectType.define do
  name "Task"
  field :state, types.String
end
