# Ustack

[![Build Status](https://travis-ci.org/kostia/ustack.png)](https://travis-ci.org/kostia/ustack)
[![Code Climate](https://codeclimate.com/github/kostia/ustack.png)](https://codeclimate.com/github/kostia/ustack)

![Elbenwald](https://raw.github.com/kostia/ustack/master/ustack.png)

Micro middleware stack for general purpose.

## Installation

```ruby
# Gemfile
gem 'ustack'
```

## Basic usage

```ruby
class M1 < Struct.new(:app)
  def call(env)
    puts self
    puts app.call(env)
    puts self
    'zzz'
  end
end

class M2 < Struct.new(:app, :options)
  def call(env)
    puts self
    options[:return]
  end
end

app = Ustack.new do
  use M1
  use M2, return: 'xxx'
end

puts app.run
# => M1
# => M2
# => xxx
# => M1
# => zzz
```

You can also `swap`, `insert_before` and `insert_after` middleware. See documentation for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright (c) 2013 Kostiantyn Kahanskyi

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
