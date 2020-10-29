# rancherdeploy

# 2 Alter default IP docker
Docker uses the default 172.17.0.0/16 subnet for container networking. If this subnet is not available for docker in your environment (for example because your network already uses this subnet), you must configure Docker to use a different subnet. You can perform this process across all the hosts in your system, or only on hosts deployed into environments where the 172.17.0.0/16 unavailable. In a multihost deployment, there is no requirement that all hosts use the same subnet for Docker container communications.

Procedure

Stop the Resource Manager services running on the host (for example the entire Resource Manager application if this procedure is being completed on a master server).

Shut down serviced and Docker on the host by typing the following on the host command line:
 $ systemctl stop serviced
 $ systemctl stop docker

Remove the existing MASQUERADE rules from the POSTROUTING chain in iptables:

iptables -t nat -F POSTROUTING

Remove the existing IP address from the Docker bridge device:
 $ ip link set dev docker0 down
 $ ip addr del 172.17.42.1/16 dev docker0

Pick a subnet you won't need to route to/from your collector. The /24 should be appropriate, unless you require more than 255 containers on a given host. The following example uses 192.168.5.0/24:
 $ ip addr add 192.168.5.1/24 dev docker0
 $ ip link set dev docker0 up

Verify that the interface has the correct IP set:
 $ ip addr show docker0

You should see a result similar to the following (the 'state DOWN' is expected at this stage):

docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN
 link/ether 56:84:7a:fe:97:99 brd ff:ff:ff:ff:ff:ff
 inet 192.168.5.1/24 scope global docker0
 valid_lft forever preferred_lft forever

Start Docker:
 $ systemctl start docker 

Verify that the MASQUERADE rule for your new subnet has been added to the POSTROUTING chain:
 $ iptables -t nat -L -n

As part of the response, you should expect to see the following for your Docker subnet:
  Chain POSTROUTING (policy ACCEPT)
  target prot opt source destination
  MASQUERADE all -- 192.168.9.0/24 0.0.0.0/0

If you see those expected results, start serviced:
$ sytemctl start service


# Kube Info

Deploy kubernetes and Helm 

helm install rancher rancher-latest/rancher --namespace cattle-system --set hostname=*REAL-FQDN-THAT-RESOLVES* --set ingress.tls.source=secret <-- What is this??? --set privateCA=true --kubeconfig ./kube_config_cluster.yaml <-- Get Default Rancher yaml
