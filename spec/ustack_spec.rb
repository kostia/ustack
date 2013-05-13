require 'ustack'

describe Ustack do
  class M1 < Struct.new(:app)
    def call(env)
      env[:call_stack] << 'm1-before'
      env[:call_stack] << app.call(env)
      env[:call_stack] << 'm1-after'
      'from-m1'
    end
  end

  class M2 < Struct.new(:app, :options)
    def call(env)
      env[:call_stack] << options[:option_for_m2]
      'from-m2'
    end
  end

  let :app do
    Ustack.new do
      use M1
      use M2, option_for_m2: 'option-for-m2'
    end
  end

  it 'correctly calls middleware stack' do
    env = {call_stack: []}
    expect { app.run(env).should eq('from-m1') }.to change { env[:call_stack] }.
        from([]).to(%w[m1-before option-for-m2 from-m2 m1-after])
  end
end
