# nsq-cluster

Easily start up a local NSQ cluster. This is great for testing.

```ruby
# Start a cluster of 3 nsqd's and 2 nsqlookupd's
cluster = NsqCluster.new(nsqd_count: 3, nsqlookupd_count: 2)

# Stop the 3rd nsqd instance
cluster.nsqd.last.stop

# Start it back up again
cluster.nsqd.last.start

# Tear down the whole cluster
cluster.destroy
```

Available methods that map to [`nsqd`'s](http://nsq.io/components/nsqd.html) HTTP endpoints.

```ruby
# nsqd
nsqd = cluster.nsqd.first

# Create a topic
nsqd.create(topic: 'stats')

# Create a channel for a known topic
nsqd.create(topic: 'stats', channel: 'default')

# Follow the same argument pattern for #delete, #empty, #pause, and #unpause

# Get stats in JSON format
nsqd.stats

# Ping nsqd
nsqd.ping

# Get general information
nsqd.info
```

Available methods that map to [`nsqlookupd`'s](http://nsq.io/components/nsqlookupd.html) HTTP endpoints.

```ruby
#nsqlookupd
nsqlookupd = cluster.nsqlookupd.first

# Look up list of producers by topic
nsqlookupd.lookup('stats')

# Get a list of known topics
nsqlookupd.topics

# Get a list of known channels for a topic
nsqlookupd.channels('stats')

# Get a list of known nodes
nsqlookupd.nodes

# Delete a topic
nsqlookupd.delete(topic: 'stats')

# Delete a channel for a known topic
nsqlookupd.delete(topic: 'stats', channel: 'default')

# Ping nsqlookupd
nsqlookupd.ping

# Get general info
nsqlookupd.info
```