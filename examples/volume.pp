node 'cloud-dev-405-a12-02.puretec.purestorage.com' {

  volume{ 'pure_storage_volume':
                ensure      => 'absent',
                volume_name => 'test_02',
                volume_size => '1.0G',
        }
}
