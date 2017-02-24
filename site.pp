#Example of Puppet Device
node 'cloud-dev-405-a12-02.puretec.purestorage.com' { #--> This is Device name
        volume{ 'pure_storage_volume':
                #ensure either "present" or "absent"
                ensure      => 'present',
                volume_name => 'test_device_volume_1',
                volume_size => '2.5G',
        }
        hostconfig{ 'pure_storage_host':
                ensure       => 'present',
                host_name    => 'test-device-host',
                host_iqnlist => ['iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03f','iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03g'],
        }
        connection{ 'pure_storage_connection':
                ensure      => 'present',
                host_name   => 'test-device-host',
                volume_name => 'test_device_volume_1',
                #Added dependency on volume and host resource types
                #to be present, other wise connection will fail.		
                require     => [Volume['pure_storage_volume'],
                  Hostconfig['pure_storage_host']
                ],
        }

}
#Example of Puppet Agent
node 'calsoft-puppet-agent.puretec.purestorage.com'{ #--> This is Agent vm name
    #Note : device_url is MANDATORY here.	
    $device_url = 'https://pureuser:pureuser@cloud-dev-405-a12-02.puretec.purestorage.com'

      volume{ 'pure_storage_volume':
                #ensure either "present" or "absent"
                ensure      => 'present',
                volume_name => 'test_agent_volume_1',
                volume_size => '1.0G',
                device_url  => $device_url,
      }
      hostconfig{ 'pure_storage_host':
                ensure       => 'present',
                host_name    => 'test-agent-host',
                host_iqnlist => ['iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03h','iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e0i'],
                device_url   => $device_url,
      }
      connection{ 'pure_storage_connection':
                ensure      => 'present',
                host_name   => 'test-agent-host',
                volume_name => 'test_agent_volume_1',
                #Added dependency on volume and host resource types
                #to be present, other wise connection will fail.
                require     => [Volume['pure_storage_volume'],
                  Hostconfig['pure_storage_host']
                  ],
                #Mandatory only for Puppet Apply and Agent approach.
                device_url  => $device_url,
      }
}
#Example of Puppet Apply
node 'puppet.puretec.purestorage.com'{ #--> This is master vm name
    #Note: device_url is MANDATORY here. 		
    $device_url = 'https://pureuser:pureuser@cloud-dev-405-a12-02.puretec.purestorage.com'

      volume{ 'pure_storage_volume':
                #ensure either "present" or "absent"
                ensure      => 'present',
                volume_name => 'test_apply_volume_1',
                volume_size => '1.0G',
                device_url  => $device_url,
      }
      hostconfig{ 'pure_storage_host':
                ensure       => 'present',
                host_name    => 'test-apply-host',
                host_iqnlist => ['iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03j','iqn.1994-04.jp.co.pure:rsd.d9s.t.10103.0e03k'],
                device_url   => $device_url,
      }
      connection{ 'pure_storage_connection':
                ensure      => 'present',
                host_name   => 'test-apply-host',
                volume_name => 'test_apply_volume_1',
                #Added dependency on volume and host resource types
                #to be present, other wise connection will fail.
                require     => [Volume['pure_storage_volume'],
                  Hostconfig['pure_storage_host']
                  ],
                #Mandatory only for Puppet Apply and Agent approach.
                device_url  => $device_url,
      }
}
