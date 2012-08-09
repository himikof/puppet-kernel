import 'stdlib'

# Class kernel
#
#  Provides the Linux kernel
#
# @author Nikita Ofitserov <himikof@gmail.com>
# @version 1.0
# @package kernel
#
class kernel (
  $lvm = false,
) {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      package { 'genkernel':
        ensure   => 'installed',
        tag      => 'buildhost';
      }
      portage::use_flags { 'gentoo-sources':
        context => 'kernel_gentoo_sources',
        package => 'sys-kernel/gentoo-sources',
        use     => 'symlink',
        tag     => 'buildhost'
      }
      package { 'kernel_sources':
        name     => 'gentoo-sources',
        ensure   => 'latest',
        tag      => 'buildhost',
        require  => [Portage::Use_flags['gentoo-sources']],
      }
      
      $genkernel_options = [
        $lvm ? {
          true    => "--lvm",
          default => [],
        },
        "--makeopts=\"-j${::processorcount}\"",
        "all",
      ]
      $genkernel_options_str = join(flatten($genkernel_options), ' ')
      
      exec { 'genkernel':
        command     => "/usr/bin/genkernel $genkernel_options_str",
        refreshonly => true,
        require     => Package['genkernel'],
        subscribe   => Package['kernel_sources'],
      }
    }
  }
}
