# DanarchyCouchDB

A Ruby implementation of CouchDB.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'danarchy_couchdb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install danarchy_couchdb

## Usage

A new DanarchyCouchDB object is created using a hash of connection values:

With SSL:
```ruby
conn = { host: 'hostname/IPaddr', port: '6984', user: 'cdb_user', pass: 'cdb_passwd', use_ssl: true }
```

Without SSL:
```ruby
conn = { host: 'hostname/IPaddr', port: '5984', user: 'cdb_user', pass: 'cdb_passwd', use_ssl: false }
```

Create the object:
```ruby
cdb = DanarchyCouchDB::Connection.new(conn)
```

All calls to CouchDB comprise of at least a 'database' and 'document' argument, and PUT requires an additional hash, which it will turn into JSON formatting to send to CouchDB:

```ruby
# View all databases:
cdb.get('_all_dbs', '')
=> ["_replicator", "_users", "test_suite_db", "test_suite_db2"]

database = 'test_suite_db'

# View all documents within a database:
cdb.get('test_suite_db', '_all_docs')
=> {:total_rows=>3, :offset=>0, :rows=>[{:id=>"3853a22cbc4520c65f81c8689706009a", :key=>"3853a22cbc4520c65f81c8689706009a", :value=>{:rev=>"1-027467bd0efec85f21c822a8eb537073"}}, {:id=>"3853a22cbc4520c65f81c86897060c60", :key=>"3853a22cbc4520c65f81c86897060c60", :value=>{:rev=>"1-3975759ccff3842adf690a5c10caee42"}}, {:id=>"3853a22cbc4520c65f81c86897060dc0", :key=>"3853a22cbc4520c65f81c86897060dc0", :value=>{:rev=>"1-23202479633c2b380f79507a776743d5"}}]}

# Load a document:
test_suite_db = cdb.get('test_suite_db', '3853a22cbc4520c65f81c86897060c60')
=> {:_id=>"3853a22cbc4520c65f81c86897060c60", :_rev=>"1-3975759ccff3842adf690a5c10caee42", :a=>2}

# Add a new key=>value to the document:
test_suite_db[:taxation] = 'is extortion'
p test_suite_db
=> {:_id=>"3853a22cbc4520c65f81c86897060c60", :_rev=>"1-3975759ccff3842adf690a5c10caee42", :a=>2, :taxation=>"is extortion"}

# Update the document within CouchDB:
cdb.put('test_suite_db', '3853a22cbc4520c65f81c86897060c60', test_suite_db)
=> {:ok=>true, :id=>"3853a22cbc4520c65f81c86897060c60", :rev=>"2-743ac80b9a990d2644bc92bafb452fe5"}

# We can verify the update with another cdb.get to update the hash to the latest document revision:
test_suite_db = cdb.get('test_suite_db', '3853a22cbc4520c65f81c86897060c60')
=> {:_id=>"3853a22cbc4520c65f81c86897060c60", :_rev=>"2-743ac80b9a990d2644bc92bafb452fe5", :a=>2, :taxation=>"is extortion"}

# cdb.get can also take an optional revision argument:
test_suite_db = cdb.get('test_suite_db', '3853a22cbc4520c65f81c86897060c60', '3-9de3ebabb6ea97fb4015cb698d228aec')
=> {:_id=>"3853a22cbc4520c65f81c86897060c60", :_rev=>"3-9de3ebabb6ea97fb4015cb698d228aec", :a=>2, :taxation=>"is extortion"}

# Delete a document with cdb.delete with a required revision:
cdb.delete('test_suite_db', '3853a22cbc4520c65f81c86897060c60', '3-9de3ebabb6ea97fb4015cb698d228aec')
=> {:ok=>true, :id=>"3853a22cbc4520c65f81c86897060c60", :rev=>"4-b35392a676cdbafebefaf425c6913670"}

```

## Contributing

Bug reports are welcome on GitHub at https://github.com/danarchy85/danarchy_couchdb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
