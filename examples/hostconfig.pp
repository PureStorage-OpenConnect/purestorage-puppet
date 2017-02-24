node 'cloud-dev-405-a12-02.puretec.purestorage.com' {

  hostconfig{ 'pure_storage_host':
                ensure       => 'absent',
                host_name    => 'test-host',
                host_iqnlist => 'iqn.1994-04.jp.co.hitachi:rsd.d9s.t.10103.0e02a',
            }
}
