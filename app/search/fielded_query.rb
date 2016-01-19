module Search
  class FieldedQuery
    attr_reader :field_pairs

    def initialize(field_pairs)
      @field_pairs = field_pairs
    end

    def present?
      return false unless field_pairs
      to_s.present?
    end

    def value_for(key)
      if field_pairs && field_pairs.key?(key)
        field_pairs[key]
      end
    end

    def to_s
      clauses = []
      if field_pairs
        field_pairs.each do |k, v|
          next if v.nil?
          next if v.blank?
          next if v == "*"
          clauses << clause_to_s(k, v)
        end
      end
      clauses.join(" ")
    end

    def to_h
      hash = {}
      if field_pairs
        field_pairs.each do |k, v|
          next if v.nil?
          next if v.blank?
          next if v == "*"
          hash[k] = v
        end
      end
      hash
    end

    def humanized(model)
      humanized = {}
      to_h.each do |k, v|
        attr = k.gsub('.', '_')
        humanized[model.human_attribute_name(attr)] = v
      end
      self.class.new(humanized)
    end

    private

    def clause_to_s(key, value)
      if value.to_s.match(/^\w/)
        "#{key}:(#{value})"
      else
        "#{key}:#{value}"
      end
    end
  end
end
