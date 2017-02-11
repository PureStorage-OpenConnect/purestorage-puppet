## Pure Storage Puppet Module

#### Table of Contents

  1. [Disclaimer](#disclaimer)
  2. [Overview](#overview)
  3. [Description](#description)
  4. [Setup](#setup)
    * [Connecting to a Pure Storage Array](#connecting-to-a-purestorage-array)
  5. [Usage](#usage)
    * [Puppet Device](#puppet-device)
    * [Puppet Agent](#puppet-agent)
    * [Puppet Apply](#puppet-apply)
  6. [Supported use-cases](#supported-use-cases)  
  7. [Limitations](#limitations)
  8. [Development](#development)

## Disclaimer

This provider is written as best effort and provides no warranty expressed or
implied. Please contact the author(s) via [Pure Storage Support Team](https://www.purestorage.com/support.html) if you have
questions about this module before running or modifying.

## Overview

The Pure Storage provider allows you to provision volumes on a Pure Storage array
from either a puppet client or a puppet device proxy host. The provider has
been developed against CentOS 7.2 using Puppet-4.8.1. At this stage testing
is completely manual.

## Description

Using the `volume`, `hostconfig` and `connection` types, one
can quickly provision remote storage and attach it via iSCSI from a
Pure Storage array to a client.

The provider utilizes the robust REST API (V1.6) available on the Pure Storage
array to remotely provision the necessary resources.

## Setup

### Connecting to a Pure Storage Array

A connection to a Pure Storage array is via the storage array IP address 
or FQDN name of the storage array and through use of a Admin account. 
A connection string is needed to inform the providers how to connect. 
The providers can get the connection string from various locations 
(see Usage below) but the three pieces of information necessary are:

  1. Admin account user name.
  2. Admin account password.
  3. IP address or DNS name.

If multiple connection options are provided to the provider, it will use them
in the following order:

  1. Any existing connection.
  2. A Facter-supplied URL.
  3. A user-supplied URL (in `device.conf` or `site.pp` file).

## Usage

### Puppet Device

The Puppet Network Device system is a way to configure devices' (switches,
routers, storage) which do not have the ability to run puppet agent on
the devices. The device application acts as a smart proxy between the Puppet
Master and the managed network device. To do this, puppet device will
sequentially connects to the master on behalf of the managed network device
and will ask for a catalog (a catalog containing only network device
resources). It will then apply this catalog to the said device by translating
the resources to orders the network device understands. Puppet device will
then report back to the master for any changes and failures as a standard node.

The Pure Storage providers are designed to work with the puppet device concept and
in this case will retrieve their connection information from the `url` given
in Puppet's `device.conf` file. An example is shown below:

     [array1.puretec.purestorage.com]
      type pure
      url https://<admin>:<password>@puretec.purestorage.com

In the case of Puppet Device connection to the Pure Storage is from the machine
running 'device' only.

command : "puppet device"

### Puppet Agent

Puppet agent is the client/slave side of the puppet master/slave relationship.
In the case of puppet agent the connection information needs to be included in
the manifest supplied to the agent from the master or it could be included
in a custom fact passed to the client. The connection string must be supplied
as a URL. See the example manifests (complete_create.pp) for details.

In the case of Puppet Agent, connections to the Pure Storage array will be
initiated from every machine which utilizes the Pure Storage puppet module this
way. This may be of security concern for some folks.

Command: "puppet agent -t"

### Puppet Apply

Puppet apply is the client only application of a local manifest. Puppet apply
is supported similar to puppet agent by the Pure Storage providers. 
The connection string must be supplied as a URL. See the example 
manifests (complete_create.pp) for details.

Command: "puppet apply <manifest_file_path>"
	e.g. "puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp"

## Supported use-cases:

   1. create \ update \ delete volume
        * Array of iqn-list supported
        eg.  host_iqnlist =>  ["iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03j","iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03k"],
        ** volume size cannot be reduced REST API constraint.
   2. create \ update \ delete host
   3. create \ delete connection

## Limitations

Today the Pure Storage puppet module supports create, update, delete of 
volume, host and direct connection (between the two). 
Currently it only supports iSCSI connections and IQN ids.

## Development

Please see the [Pure Storage](https://www.purestorage.com/support.html) for any issues,
discussion, advice or contribution(s).

To get started with developing this module, you'll need a functioning Ruby installation.