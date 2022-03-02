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

    # initilize
    new_class.define_method(:initialize) do |*variables|
      exeption_message = "wrong number of arguments (given #{variables.size}, expected #{args.size})"
      raise ArgumentError, exeption_message if args.size < variables.size

      args.each_with_index do |key, index|
        instance_variable_set("@#{key}", variables[index])
      end
    end

    # []
    new_class.define_method('[]') do |type|
      case type
      when Integer
        raise StandardError, 'size limit' if args.size < type

        instance_variable_get("@#{args[type]}")
      when Symbol
        instance_variable_get("@#{type}")
      when String
        instance_variable_get("@#{type}")
      end
    end

    # []=
    new_class.define_method('[]=') do |type, value|
      case type
      when Integer
        raise StandardError, 'size limit' if args.size < type

        instance_variable_set("@#{args[type]}", value)
      when Symbol
        instance_variable_set("@#{type}", value)
      when String
        instance_variable_set("@#{type}", value)
      end
    end

    # each
    new_class.define_method('each') do |&each_block|
      args.each do |arg|
        each_block.call(instance_variable_get("@#{arg}")) if each_block
      end
    end

    # each_pair
    new_class.define_method('each_pair') do |&each_pair_block|
      args.each do |arg|
        each_pair_block.call(arg.to_s, instance_variable_get("@#{arg}")) if each_pair_block
      end
    end

    # size, length
    new_class.define_method('size') do
      args.size
    end
    new_class.alias_method 'length', 'size'

    # members
    new_class.define_method('members') do
      args
    end

    # select
    new_class.define_method('select') do |&select_block|
      args.map do |arg|
        instance_variable_get("@#{arg}") if select_block.call(instance_variable_get("@#{arg}"))
      end.compact
    end

    # to_a
    new_class.define_method('to_a') do
      args.map do |arg|
        instance_variable_get("@#{arg}")
      end
    end

    # values_at
    new_class.define_method('values_at') do |*numbers|
      numbers.map do |num|
        instance_variable_get("@#{args[num]}")
      end
    end

    # eql?, ==
    new_class.define_method('==') do |obj|
      return false if obj.class != self.class

      args.each do |arg|
        return false if instance_variable_get("@#{arg}") != obj.instance_variable_get("@#{arg}")
      end
    end
    new_class.alias_method 'eql?', '=='

    # dig
    new_class.define_method('dig') do |*keys|
      keys.each_with_index do |key, index|
        return self[key] if index == keys.size - 1
        return nil unless self[key]
        return self[key].dig(*keys[1..]) if self[key][keys[index + 1]]

        return nil
      end
    end

    new_class.class_eval(&block) if block_given?

    Factory.const_set(args.shift, new_class) if args.first.is_a? String

    new_class
  end
end
