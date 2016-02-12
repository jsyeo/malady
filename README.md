# Malady [![Build Status](https://travis-ci.org/jsyeo/malady.svg?branch=master)](https://travis-ci.org/jsyeo/malady)

Malady is an implementation of [mal](https://github.com/kanaka/mal) that compiles to [Rubinius](http://rubinius.com) bytecode.

## Installation

```bash
$ gem install malady
```

## Usage

Use the `malady` binary provided in the `bin` directory to execute the malady repl.

```bash
$ malady
malady> (+ 42 88)
130
malady>
```

## Development

Malady requires [Rubinius](http://rubinius.com).

Install dependencies with bundle

```bash
$ bundle install
```

To run tests, use rspec

```bash
$ rspec
```

## To Do:

- [ ] Data structures
  - [ ] Lists
  - [ ] Hashes
  - [ ] Symbols
- [ ] Macros
- [ ] Import mal's test cases

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jsyeo/malady.


## Credits

Inspired by [lani](https://github.com/queenfrankie/lani), a programming language in Rubinius.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

