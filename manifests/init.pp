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
      $kernel_sources = 'gentoo-sources'
      portage::use_flags { 'kernel_sources':
        context => 'kernel_sources',
        package => "sys-kernel/$kernel_sources",
        use     => 'symlink',
        tag     => 'buildhost'
      }
      package { 'kernel_sources':
        name     => $kernel_sources,
        ensure   => 'latest',
        tag      => 'buildhost',
        require  => [Portage::Use_flags['kernel_sources']],
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
        timeout     => 0,
        require     => Package['genkernel'],
        subscribe   => Package['kernel_sources'],
      }
    }
  }
}
