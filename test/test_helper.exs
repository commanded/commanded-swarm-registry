ExUnit.start()

# Spawn a cluster to test process distribution using Swarm
Commanded.Cluster.spawn()

Application.put_env(:commanded, :reset_storage, &Commanded.Storage.reset!/0)
