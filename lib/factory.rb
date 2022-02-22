# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?
class Factory
	def self.new(*args, &block)
		new_class = Class.new
		new_class.send(:attr_accessor, *args.map(&:to_sym))
		new_class.define_method(:initialize) do |*variables|
      raise ArgumentError.new('size limit') if args.size < variables.size

      args.each_with_index do |key, index|
        instance_variable_set("@#{key}", variables[index])
      end
    end
		new_class.define_method('[]') do |type|
      case type
      when Integer
        raise ArgumentError.new('size limit') if args.size < type

        instance_variable_get("@#{args[type]}")
      when Symbol
        instance_variable_get("@#{type}")
      when String
        instance_variable_get("@#{type}")
      end
    end
    new_class.define_method('[]=') do |type, value|
      case type
      when Integer
        raise ArgumentError.new('size limit') if args.size < type

        instance_variable_set("@#{args[type]}", value)
      when Symbol
        instance_variable_set("@#{type}", value)
      when String
        instance_variable_set("@#{type}", value)
      end
    end
		yield new_class if block_given? 
		new_class
	end
end

# p F = Factory.new(:a)
# p f = F.new(1)
# p f.a
# p f['a']
# p f[:a]
# p f[0]
# f['a'] = 5
# p f['a']
# f[:a] = 6
# p f[:a]
# f[0] = 7
# p f[0]