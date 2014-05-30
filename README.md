# Goldmine

A simple, [fortune](http://en.wikipedia.org/wiki/Fortune_(Unix)) cookie library for Ruby.
Goldmine provides access to the contents of a fortune file. The fortune file is a database
which contains fortunes ― funny, offensive, serious and reflective (very rarely) quotes, jokes, or poems. [Example](http://github.com/Archetylator/goldmine/blob/master/fortunes/fortunes).

Goldmine allows to create and read a data file which describes the database.
Such a file is called an index. The index always has the same name as the database, but ends with a ".dat" extension. The index created by Goldmine is
compatible with a [fortune program](http://stuff.mit.edu/afs/sipb/project/freebsd/head/games/fortune/fortune/fortune.c) written by [Ken Arnold](http://en.wikipedia.org/wiki/Ken_Arnold).

Install
--------

```shell
gem install goldmine
```
or add this to your Gemfile:

```ruby
gem "goldmine"
```
and run `bundle install` command.

Getting Started
----------------

Create a Goldmine::DB instance that points to a fortune file. After that you have access to that collection via a few methods.

```ruby
db = Goldmine::DB.new(path: "/home/user/fortunes")
puts db.random # Throws a random fortune
puts db.fortunes # Returns all fortunes
```

If you don't pass the file path, Goldmine will use default fortunes database which was prepared by [Brian M. Clapper](https://github.com/bmc/fortunes/).

### Options

By passing `comments: true` option you specify that your fortunes collection includes comments. A comment is identified as a double delimiter at the begging of the line.

You could also define a delimiter by passing `delim: "character"` option. The default delimiter is a percent sign.

```ruby
Goldmine::DB.new(path: "/my/fortunes/path", comments: true, delim: "#")
```

### Database with an index

If you need to access the database using the index, use Goldmine::IDB class.

```ruby
Goldmine::IDB.new(path: "/my/fortunes/path")
```

You can't pass options to Goldmine::IDB because all options are extracted from the index file.

### Fortune

An instance of Goldmine::Fortune class represents a single fortune. Wherever Goldmine returns a single fortune or bundle of them in fact it returns Goldmine::Fortune instances.

```ruby
fortune = Goldmine::DB.new.random
fortune.content # Returns a body of the fortune
fortune.attribution # Returns an attribution if exists
```

### Create an index

You can pass many options when creating an instance. To learn about all the possibilities, please see the documentation.

```ruby
writer = Goldmine::IndexWriter.new("/path/to/database")
writer.write
```

Ideas & bugs
-------

Please submit to [issues](http://github.com/Archetylator/goldmine/issues)

License
-------

"THE BEER-WARE LICENSE" (Revision 42):
Marcin "Archetylator" Syngajewski wrote this file. As long as you retain this notice you
can do whatever you want with this stuff. If we meet some day, and you think
this stuff is worth it, you can buy me a beer in return.