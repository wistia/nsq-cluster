# nsq-cluster

Easily start up a local NSQ cluster. This is great for testing.

```ruby
# Start a cluster of 3 nsqd's and 2 nsqlookupd's.
# This will block execution until all components are fully up and running.
cluster = NsqCluster.new(nsqd_count: 3, nsqlookupd_count: 2)

# Stop the 3rd nsqd instance and wait for it to come down.
cluster.nsqd.last.stop

# Start it back up again and wait for it to fully start.
cluster.nsqd.last.start

# Tear down the whole cluster.
cluster.destroy
```

## Compatibility

- Version 2.x of `nsq-cluster` is compatible with NSQ >= 1.0.
- Version 1.x of `nsq-cluster` is compatible with NSQ < 1.0.

## Flags for nsqd and nsqlookupd

Optionally, you can pass in flags for nsqd and nsqlookupd like this:

```ruby
NsqCluster.new(
  nsqd_count: 1,
  nsqlookupd_count: 1,
  nsqd_options: { verbose: true },
  nsqlookupd_options: { verbose: true }
)
```

## Send commands to nsqd

Available methods that map to [`nsqd`'s](http://nsq.io/components/nsqd.html) HTTP endpoints.

```ruby
# nsqd
nsqd = cluster.nsqd.first

# Publish a message to a topic
nsqd.pub('stats', 'a message')

# Publish multiple messages to a topic
nsqd.mpub('stats', 'a message', 'a second message', 'last message')

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

## Send commands to nsqlookup

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
