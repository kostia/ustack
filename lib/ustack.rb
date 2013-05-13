require 'ustack/version'

class Ustack
  def initialize(&block)
    instance_eval(&block) if block_given?
  end

  def use(klass, options=nil)
    @ustack ||= []
    @ustack << [klass, options]
  end

  def run(env={})
    @ustack.reverse.each do |(klass, options)|
      @app = options ? klass.new(@app, options) : klass.new(@app)
    end
    @app.call(env)
  end
end
