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
      env[:call_stack] << app.call(env) if app
      'from-m2'
    end
  end

  class M3 < Struct.new(:app, :options)
    def call(env)
      env[:call_stack] << options[:option_for_m3]
      'from-m3'
    end
  end

  let :app do
    Ustack.new do
      use M1
      use M2, option_for_m2: 'option-for-m2'
    end
  end

  let(:env) { {call_stack: []} }

  it 'correctly calls middleware stack' do
    expect { app.run(env).should eq('from-m1') }.to change { env[:call_stack] }.
        from([]).to(%w[m1-before option-for-m2 from-m2 m1-after])
  end

  it 'swaps middleware' do
    app.swap(M2, M3, option_for_m3: 'option-for-m3')
    expect { app.run(env).should eq('from-m1') }.to change { env[:call_stack] }.
        from([]).to(%w[m1-before option-for-m3 from-m3 m1-after])
  end

  describe '#index_before' do
    class InsertBefore < Struct.new(:app, :options)
      def call(env)
        env[:call_stack] << options[:option_for_insert_before]
        env[:call_stack] << app.call(env)
        'from-insert-before'
      end
    end

    it 'inserts before given middleware' do
      app.insert_before(M2, InsertBefore, option_for_insert_before: 'option-for-insert-before')
      expect { app.run(env).should eq('from-m1') }.to change { env[:call_stack] }.
          from([]).to(%w[m1-before option-for-insert-before option-for-m2 from-m2
                         from-insert-before m1-after])
    end

    it 'inserts before very first middleware' do
      app.insert_before(M1, InsertBefore, option_for_insert_before: 'option-for-insert-before')
      expect { app.run(env).should eq('from-insert-before') }.to change { env[:call_stack] }.
          from([]).to(%w[option-for-insert-before m1-before option-for-m2 from-m2 m1-after from-m1])
    end
  end

  describe '#index_after' do
    class InsertAfter < Struct.new(:app, :options)
      def call(env)
        env[:call_stack] << options[:option_for_insert_after]
        env[:call_stack] << app.call(env) if app
        'from-insert-after'
      end
    end

    it 'inserts after given middleware' do
      app.insert_after(M1, InsertAfter, option_for_insert_after: 'option-for-insert-after')
      expect { app.run(env).should eq('from-m1') }.to change { env[:call_stack] }.
          from([]).to(%w[m1-before option-for-insert-after option-for-m2 from-m2
                         from-insert-after m1-after])
    end

    it 'inserts after very last middleware' do
      app.insert_after(M2, InsertAfter, option_for_insert_after: 'option-for-insert-after')
      expect { app.run(env).should eq('from-m1') }.to change { env[:call_stack] }.
          from([]).to(%w[m1-before option-for-m2 option-for-insert-after
                         from-insert-after from-m2 m1-after])
    end
  end
end
