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
