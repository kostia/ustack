require 'ustack/version'

class Ustack
  def initialize(&block)
    instance_eval(&block) if block_given?
  end

  def use(klass, options=nil)
    @stack ||= []
    @stack << [klass, options]
  end

  def run(env={})
    @stack.reverse.each do |(klass, options)|
      @app = options ? klass.new(@app, options) : klass.new(@app)
    end
    @app.call(env)
  end
end
