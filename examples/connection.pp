 node 'cloud-dev-405-a12-02.puretec.purestorage.com' {

  connection{ 'pure_storage_connection':
                ensure      => 'absent',
                host_name   => 'test-host',
                volume_name => 'test_02',
            }
}
