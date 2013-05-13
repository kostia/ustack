require 'ustack/version'

# Micro middleware stack for general purpose.
#
# @example
#   class M1 < Struct.new(:app)
#     def call(env)
#       puts self
#       puts app.call(env)
#       puts self
#       'zzz'
#     end
#   end
#
#   class M2 < Struct.new(:app, :options)
#     def call(env)
#       puts self
#       options[:return]
#     end
#   end
#
#   app = Ustack.new do
#     use M1
#     use M2, return: 'xxx'
#   end
#
#   puts app.run
#   # => M1
#   # => M2
#   # => xxx
#   # => M1
#   # => zzz
#
# @api public
class Ustack
  # Initializes new middleware stack.
  #
  # @example
  #   app1 = Ustack.new
  #   app2 = Ustack.new do
  #     use M1
  #     use M2, my_option: 'xxx'
  #   end
  #
  # @return [Ustack] Initialized middleware stack.
  # @api public
  def initialize(&block)
    instance_eval(&block) if block_given?
  end

  # Tells the stack to use given middleware.
  #
  # @param [Class] klass Middleware class to be used.
  # @param [Hash] options Hash of orbitrary options for new middlware.
  #
  # @example
  #   app = Ustack.new do
  #     use M1
  #   end
  #   app.use M2
  #   app.use M2, my_option: 'xxx'
  #
  # @api public
  def use(klass, options=nil)
    @ustack ||= []
    @ustack << [klass, options]
  end

  # Swaps two middlewares.
  #
  # @param [Class] old_klass Middleware class to be replaced.
  # @param [Class] new_klass New middleware class.
  # @param [Hash] options Hash of orbitrary options for new middlware.
  #
  # @example
  #   app = Ustack.new do
  #     use M1
  #   end
  #   app.use M2
  #   app.use M2, my_option: 'xxx'
  #
  # @api public
  def swap(old_klass, new_klass, options=nil)
    @ustack[index(old_klass)] = [new_klass, options]
  end

  # Insert a middleware before another middleware.
  #
  # @param [Class] klass Existing middleware.
  # @param [Class] new_klass Middleware to be inserted.
  # @param [Hash] options Hash of orbitrary options for new middlware.
  #
  # @example
  #   app = Ustack.new do
  #     use M1
  #   end
  #   app.insert_before M1, M0, my_option: 'xxx'
  #
  # @api public
  def insert_before(klass, new_klass, options=nil)
    @ustack.insert(index(klass), [new_klass, options])
  end

  # Insert a middleware after another middleware.
  #
  # @param [Class] klass Existing middleware.
  # @param [Class] new_klass Middleware to be inserted.
  # @param [Hash] options Hash of orbitrary options for new middlware.
  #
  # @example
  #   app = Ustack.new do
  #     use M1
  #   end
  #   app.insert_before M1, M2, my_option: 'xxx'
  #
  # @api public
  def insert_after(klass, new_klass, options=nil)
    @ustack.insert(index(klass) + 1, [new_klass, options])
  end

  # Runs the middlware stack.
  #
  # @param [Hash] env Initial environment.
  #
  # @example
  #   class M1 < Struct.new(:app)
  #     def call(env)
  #       app.call(env)
  #       'zzz'
  #     end
  #   end
  #
  #   class M2 < Struct.new(:app)
  #     def call(env)
  #       puts env[:my_env_key]
  #     end
  #   end
  #
  #   app = Ustack do
  #     use M1
  #     use m2
  #   end
  #
  #   puts app.run(my_env_key: 'xxx')
  #   # => 'xxx'
  #   # => 'zzz'
  #
  # @return [Object] Value returned by the most outer middleware.
  # @api public
  def run(env={})
    app = nil
    @ustack.reverse.each do |(klass, options)|
      app = options ? klass.new(app, options) : klass.new(app)
    end
    app.call(env)
  end

  private

  def index(klass, &block)
    @ustack.each_with_index { |(k, _), i| return i if k == klass }
  end
end
