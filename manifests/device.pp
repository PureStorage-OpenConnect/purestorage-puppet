# Define the authentication type
define pure::device (
  $hostname,
  $username,
  $password,
  $target = undef,
  ) {
  # validate_string($hostname)
  # validate_string($username)
  # validate_string($password)

  # $device_config = pick($target, $::settings::deviceconfig)

  #validate_absolute_path($device_config)

  augeas { "device.conf/${name}":
    lens    => 'Puppet_Device',
    incl    => $::device_config,
    context => $::device_config,
    changes => [
      "set ${name}/type pure",
      "set ${name}/url https://${username}:${password}@${hostname}",
    ]
  }
}
