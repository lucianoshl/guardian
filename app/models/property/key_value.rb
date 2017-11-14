class Property::KeyValue < Property::Simple
    field :key, type: String
    def self.get key,default=""
        model = where(key: key).first
        model.nil? ? default : content
    end

    def self.set(key,value)
        model = where(key: key).first
        model = Property::KeyValue.new if model.nil? 
        model.key = key
        model.content = value
        model.save
    end

    def self.method_missing(m, *args, &block) 
        if (args.size == 1)
            return get(m.to_s,args.first) 
        end

        if (args.size == 0)
            model = where(key: m.to_s).first
            model = Property::KeyValue.new if model.nil?
            model.key = m.to_s
            return model
        end
    end
end