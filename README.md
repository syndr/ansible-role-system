System Configuration
=========

[![Role - system](https://github.com/syndr/ansible-role-system/actions/workflows/role-system.yml/badge.svg)](https://github.com/syndr/ansible-role-system/actions/workflows/role-system.yml)

Configure the fundamentals of the system needed in order for it to be usable within the chosen deployment environment.

These include:
- System hostname
- Shell customizations
- Kernel options
- System package manager confiugration
- System package auto-updates
- Base packages installed via system package manager
- System application alternatives (update-alternatives)
- System logging (log file rotation, etc)
- SSH configuration
- System timezone
- System cron jobs
- System MOTD

Requirements
------------

A target host with appropriate networking and credentials that Ansible can access it.

Collections:
- ansible.posix
- community.general

Role Variables
--------------

```yaml
### Enable/Disable Role Features ## {{{
# Set the system hostname
system_enable_hostname: true

# Manage kernel options, etc.
system_enable_kernel: true

# Manage packages on the system
system_enable_packages: true

# Manage automatic package updates using yum-cron, dnf-automatic, etc.
#  - Requires system_enable_packages to be enabled
#  - Requires system_enable_utilities to be enabled
system_enable_packages_auto_update: true

# Configure system application alternatives, as done by the 'update-alternatives' tool
system_enable_alternatives: true

# Manage system services such as NTP and SSH
system_enable_services: true

# Manage system shell configuration, such as aliases, etc.
system_enable_shell: true

# Manage system MOTD
system_enable_motd: true

# Manage system logging using logrotate, journald
system_enable_logging: true

# Install system-wide pip packages
system_enable_pip_packages: true

# Manage system timezone
system_enable_timezone: true

# Manage system cron jobs
system_enable_cron: true

# Deploy system utility scripts
system_enable_utils: true

# Install location for system tools used by the configuration deployed by this role
# NOTE: These should be always be installed outside of extraordinary circumstances
#       Failure to deploy may result in unexpected behavior
#        - set to an empty string to disable
system_tools_bin: /usr/local/bin

# }}}


## Network Configuration ## {{{

# Hostname for the target machine
system_hostname: "{{ inventory_hostname }}"

# }}}


## Shell Configuration ## {{{
system_bash_aliases:
  ll: "ls -alF"
  la: "ls -A"
  l: "ls -CF"

# }}}


## MOTD Configuration ## {{{
system_motd_banner: |
  +                                                                                       +
                        .o.         .oooooo.   ooo        ooooo oooooooooooo
                       .888.       d8P'  `Y8b  `88.       .888' `888'     `8
                      .8"888.     888           888b     d'888   888
      \    /\        .8' `888.    888           8 Y88. .P  888   888oooo8
       )  ( ')      .88ooo8888.   888           8  `888'   888   888    "
      (  /  )      .8'     `888.  `88b    ooo   8    Y     888   888       o
       \(__)|     o88o     o8888o  `Y8bood8P'  o8o        o888o o888ooooood8

                             Advanced Computer Mouse Endangerment
  +                                                                                       +

# The version of the motd configuration. If set to an empty string, the git hash
#  of the project containing the originating playbook will be used.
system_motd_config_version: "{{ awx_project_revision | default(lookup('env', 'PROJECT_VERSION') | default('')) }}"

# List of static messages that should be included in the MOTD
# - Each message should be a dictionary with the following keys:
#     name: Name of the message (format '##-name')
#     content: The content of the message
#     state: Whether the message should be present or absent (default present)
#
# - The 'banner' name is reserved for the MOTD banner message, however its ordering can be modified
#   here if desired by changing the '#' part of the name
# - the '95-config-status' message is reserved for the configuration data set by 'system_motd_status_data'
system_motd_static_messages:
  - name: 30-banner
    content: "{{ system_motd_banner }}"
    state: present
  - name: 90-ansible-warning
    content: "WARNING: This host is managed by Ansible! Manual changes may revert automagically!"
    state: present

# List of filenames that should be removed if they're in the update-motd.d directory
# - Defaults to an internal list of known conflicting default files
system_motd_blacklist: "{{ __system_compat_motd_blacklist | default([]) }}"

# Title of 'status' section in the MOTD
system_motd_status_header: "Configuration Status:"

# Data that should be included in the 'status' section of the MOTD
#  - Store as a dictionary of key-value pairs, where the key is the title and the value is the data
system_motd_status_data:
  Role: "{{ role | default('base') }}"

# Should the system attempt to automatically enable the MOTD
# - This will attempt to enable the MOTD if PAM is available and the 'update-motd' command is not available
system_motd_pam_autoconfig: true

# }}}


## Kernel Configuration ## {{{
system_sysctl:
  vm.max_map_count: 262144
  kernel.printk: 4 4 1 7
  vm.min_free_kbytes: "{{ ((ansible_memtotal_mb * 1000)  * 0.045) | int}}"

# Additional kernel parameters that should be configured in addition to the standard set
system_extra_sysctl: {}

# Should the system be allowed to go into sleep mode for power saving
system_power_allow_sleep: false

# }}}


## Cron Configuration ## {{{

# List of cron jobs that should be configured on the system
# - Each job should be a dictionary with the following keys:
#   - name: Name of the cron job (upper and lower-case letters, digits, underscores, and hyphens)
#   - job: The command or script to execute
#   - user: The user that the cron job should run as (default root)
#   - minute: Minute to run the job
#   - hour: Hour to run the job
#   - day: Day of the month to run the job (exclusive with weekday)
#   - weekday: Day of the week to run the job (exclusive with day)
#       values: (0-6 for Sunday-Saturday, *)
#   - special_time: Special time to run the job (exclusive with minute, hour, and day)
#       values: daily, hourly, monthly, weekly, yearly, reboot, annually
#   - env: Dict of environment variables to set for the job (optional)
#       specify as key: value pairs
#       specify with no value to remove an environment variable
#   - state: Whether the job should be present or absent (default present)
system_cron_jobs: []

# }}}


## Packages configuration ## {{{
# Set to 'DEFAULT' for default packages, otherwise provide list of package names
# Default packages for an OS are defined in defaults/packages-distro.yml files
system_packages_base: DEFAULT

## NOTE: If `DEFAULT` is set for system_packages_base, actual default packages will be loaded from defaults/packages-<distro>-<version>.yml files
#        This can optionally also include overrides for the base pip3 packages defined below.

# Packages that should be installed in addition to the base packages. Meant to be overridden by the playbook running this role.
system_packages_extra: []

# Pip3 packages that should be installed as the root user
system_packages_pip3_base:
  requests:
    version: "2.31.0"

# Pip3 packages that should be installed in addition to the base packages. Installed as the root user. Usage same as system_packages_extra
system_packages_pip3_extra: {}

# Number of kernels permitted on a system
system_retain_kernels: 2 # num kernels retained on a system during updates

# The category of packages that should be automatically updated (IE: default, security, etc.)
#  - If using 'security', the OS must be in the (internal) list of '__system_packages_errata_distros'
#  - Setting to 'security' on OSs without errata will result in no packages being updated
system_packages_auto_update_category: security

# List of packages that should not be automatically updated
system_packages_auto_update_exclusions:
  - kernel*
  - docker*

# What time should the system automatically update packages
#  - Random wait time is added to prevent all systems from updating at the same time
system_packages_auto_update_weekly_schedule:
  weekday: Tuesday
  hour: 15  # 3pm UTC
  minute: 0

# Random wait time for package updates (in minutes)
#  - applied to daily and weekly updates
system_packages_auto_update_random_wait: 360

# }}}


## Alternatives Configuration ## {{{
#

# List of alternatives that should be configured on the system
# - Each alternative should be a dictionary with the following keys:
#     name: Name of the alternative
#     link: Path to the alternative (generic) executable
#     path: Path to the actual executable
#     priority: Priority of the alternative (default 50)
#     state: How the alternative should be configured (default auto) [present/absent/selected/auto]
system_alternatives: []

# }}}


## Time configuration ## {{{
# A list of time servers that should be configured. Set to [] to skip.
system_ntp_servers:
  - 132.163.96.3   # NIST, Boulder, Colorado

# }}}


## SSH Configuration ## {{{

# SSH configuration settings
#  - Some example configuration files are provided with this role at 'templates/etc/ssh/''
#  - Provide values as desired to override defaults in the sshd_config file
#  - Values are in the format of 'ConfigOption: value'
#    - For 'yes' or 'no' values, take care to enclose them in single quotes!
#  - For any keys that are repeated more than once (duplicated), use a list under the key
#    IE: Hostkey: [ '/etc/ssh/ssh_host_rsa_key', '/etc/ssh/ssh_host_ecdsa_key' ]
system_sshd_config:
  ChallengeResponseAuthentication: 'no'
  GSSAPIAuthentication: 'yes'
  GSSAPICleanupCredentials: 'no'
  Hostkey:
    - /etc/ssh/ssh_host_rsa_key
    - /etc/ssh/ssh_host_ecdsa_key
    - /etc/ssh/ssh_host_ed25519_key
  IgnoreRhosts: 'yes'
  LogLevel: INFO
  MaxAuthTries: 6
  MaxSessions: 30
  PasswordAuthentication: 'no'
  PermitRootLogin: 'no'
  Protocol: 2
  SyslogFacility: AUTHPRIV
  UsePAM: 'yes'
  X11Forwarding: 'no'
  AcceptEnv:
    - LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
    - LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
    - LC_IDENTIFICATION LC_ALL LANGUAGE
    - XMODIFIERS
  UseDNS: 'no'

# Default configuration settings that will always be applied unless overridden
system_sshd_config_defaults:
  Include: /etc/ssh/sshd_config.d/*.conf
  AuthorizedKeysFile: .ssh/authorized_keys

# }}}


## Logging Configuration ## {{{

# Storage configuration (persistant /var/log storage)
system_logging_max_file_size: 100M
system_logging_max_use: 1G

# How long logs should be kept on the system (days)
system_logging_retention_period: 7

# How should logs be stored (systemd/journald only)
system_logging_storage_type: auto     # volatile/persistent/auto/none

# }}}
```

Dependencies
------------

TBA

Example Playbook
----------------

```yaml
- name: Perform a basic system configuratioon
  hosts: all
  tasks:
    - name: Launch base system configuration
      ansible.builtin.include_role:
        name: system
      vars:
        system_enable_hostname: true
        system_enable_kernel: true
        system_enable_packages: true
        system_enable_services: true
        system_enable_shell: true
        system_enable_motd: true
        system_enable_logging: true
        system_enable_pip_packages: true
```

License
-------

MIT

Author Information
------------------

- [@syndr](https://github.com/syndr)
