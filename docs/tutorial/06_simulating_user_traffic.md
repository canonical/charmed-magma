# 6. Simulating user traffic

## Create an APN in Magma Orchestrator

Create an Access Point Name (APN) in Magma Orchestrator:

1. Login to `https://magma-test.nms.<your domain>`
2. Click on "Traffic" on the left panel
3. Click on "APNs"
4. Click on "Create New APN"
5. Fill in the following values:
   - APN ID: `default`
   - Class ID: `9`
   - ARP Priority Level: `15`
   - Max Required Bandwidth
     - Upload: `1000000`
     - Download: `1000000`
   - ARP Pre-emption-Capability: `Disabled`
   - ARP Pre-emption-Vulnerability: `Disabled`
6. Click on "Save"

## Add a network subscriber

Add a subscriber to the network in Magma Orchestrator:

1. Login to `https://magma-test.nms.<your domain>`
2. Click on "Subscriber" on the left panel
3. Click on "Add Subscribers"
4. Click on "Add"
5. Fill in the following values:
   - Subscriber Name: `IMSI001010000000001`
   - IMSI: `IMSI001010000000001`
   - Auth Key: `00112233445566778899aabbccddeeff`
   - Auth OPC: `63BFA50EE6523365FF14C1F45F88737D`
   - Service: `ACTIVE`
   - Data Plan: `default`
   - Active APNs: `default`
6. Click on "Save"
7. Click on "Save and Add Subscribers"

## Attach a User Equipment to the Network

Attach a User Equipment (UE) to the Network:

```{code-block} shell
juju run-action srs-enb-ue/0 attach-ue --string-args usim-imsi=001010000000001 usim-k=00112233445566778899aabbccddeeff usim-opc=63BFA50EE6523365FF14C1F45F88737D --wait
```

## Run the simulation

SSH to the machine where srsRAN is running:

```{code-block} shell
juju ssh <your srsRAN machine ID>
```

Use the UE interface to ping something on the internet, here you should expect no packet loss.

```{code-block} shell
ping -I tun_srsue google.com
```

Congratulations, you have a fully functioning 4G Network!

```{note}
Due to a bug in upstream Magma, it may happen that the UE simulator will not receive responses 
to the above ping command. 
In this situation try to ping the UE IP address from the AGW machine. If it still doesn't
work, detach the UE, restart Magma services from the AGW machine using:

sudo service magma@* stop
sudo service magma@magmad start

Once Magma is up again, connect the simulated eNodeB and UE and try pinging something again.

Bug report: https://github.com/magma/magma/issues/15196
```
