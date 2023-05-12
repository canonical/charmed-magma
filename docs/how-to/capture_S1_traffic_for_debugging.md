# Capture S1 traffic for debugging

Connect to the access gateway:

```{code-block} shell
juju ssh magma-access-gateway-operator/0
```

In the access gateway, capture S1 traffic:

```{code-block} shell
sudo tcpdump -i eth1 -s0 -w s1.pcap

# Stop the capture with Ctrl-C after running your tests

exit
```

Download the capture file:

```{code-block} shell
juju scp magma-access-gateway-operator/0:/home/ubuntu/s1.pcap
```
