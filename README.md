System Configuration
=========

[![Role - system](https://github.com/syndr/ansible-role-system/actions/workflows/role-system.yml/badge.svg)](https://github.com/syndr/ansible-role-system/actions/workflows/role-system.yml)

Configure the fundamentals of a linux system.

These include:
- System hostname
- Shell customizations (Bash)
    - System PATH
    - System aliases
    - System environment variables
    - User environment variables
    - Shell prompt
    - Command history
- Kernel options
    - Sysctl configuration
    - System power management (enable/disable sleep mode)
- System package manager configuration
- System package auto-updates
    - Schedule
    - Package categories (security, etc)
- Packages installed via system package manager
  - Number of kernels retained on the system
  - Base packages to install for system
- System application alternatives (update-alternatives)
- System logging (log file rotation, etc)
    - Logrotate configuration
    - Journald configuration
- SSH configuration
- System timezone
- System cron jobs
- System MOTD

Requirements
------------

A target host with appropriate networking and credentials that Ansible can access it.

Ansible must be able to escalate to root privileges on the target host.

Collections:
- ansible.posix
- community.general

For supported OSs, see `platforms` in [meta/main.yml](meta/main.yml).

Role Variables
--------------

```yaml
### Enable/Disable Role Features ## {{{
#

# Should the role configuration features default to enabled or disabled
#   - Sets the default value for configuration categories such as kernel, packages, motd, etc.
system_default: true

# Set the system hostname
system_enable_hostname: "{{ system_default }}"

# Manage kernel options, etc.
system_enable_kernel: "{{ system_default }}"

# Manage packages on the system
system_enable_packages: "{{ system_default }}"

# Manage automatic package updates using yum-cron, dnf-automatic, etc.
#  - Requires system_enable_packages to be enabled
#  - Requires system_enable_utils to be enabled
system_enable_packages_auto_update: "{{ system_default }}"

# Configure system application alternatives, as done by the 'update-alternatives' tool
system_enable_alternatives: "{{ system_default }}"

# Manage system services such as NTP and SSH
system_enable_services: "{{ system_default }}"

# Manage system shell configuration, such as aliases, etc.
system_enable_shell: "{{ system_default }}"

# Manage system MOTD
system_enable_motd: "{{ system_default }}"

# Manage system logging using logrotate, journald
system_enable_logging: "{{ system_default }}"

# Install system-wide pip packages
system_enable_pip_packages: "{{ system_default }}"

# Manage system timezone
system_enable_timezone: "{{ system_default }}"

# Manage system cron jobs
system_enable_cron: "{{ system_default }}"

# Deploy system utility scripts
system_enable_utils: "{{ system_default }}"

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

# List of filesystem paths that should be appended to the system PATH
system_path_append: []

### Bash History Configuration ### {{{

# Time format for bash history
system_bash_histtimeformat: "%F %T "

# Filesystem location for user bash history
system_bash_histfile: ${HOME}/.bash_history

# List of commands that should be ignored in the bash history
system_bash_histignore:
  - ls
  - ll
  - ls -alh
  - ls -lah
  - pwd
  - clear
  - history

# When the shell exits, append to the history file instead of overwriting it
system_bash_histappend: true

# Number of commands to remember for the current session
system_bash_histsize: 5000

# Maximum number of lines in the bash history file
system_bash_histfilesize: 5000

# A colon-separated list of values controlling how commands are saved on the history list
#  - 'ignorespace': commands starting with a space are not saved to the history list
#  - 'ignoredups': do not save duplicate commands
#  - 'ignoreboth': shorthand for 'ignorespace' and 'ignoredups'
system_bash_histcontrol: ignoreboth

# Command to run before the prompt is displayed
#  - Set to an empty string to disable
system_bash_prompt_command: "history -a"

### }}}

### Bash Environment Configuration ## {{{

# Aliases that should be configured for all users
#  - Each alias should be a key-value pair where the key is the alias and the value is the command
system_bash_aliases:
  # Some 'ls' customizations
  ll: "ls -alF"
  la: "ls -A"
  l: "ls -CF"
  # require prompts on common file interactions
  rm: 'rm -i'
  cp: "cp -i"
  mv: "mv -i"

# Aliases that should be configured for all users, and are only used if color is supported
#  - Each alias should be a key-value pair where the key is the alias and the value is the command
#  - Typically used for colorized output from command that support it
system_bash_coloraliases:
  ls: "ls --color=auto"
  dir: "dir --color=auto"
  vdir: "vdir --color=auto"
  grep: "grep --color=auto"
  fgrep: "fgrep --color=auto"
  egrep: "egrep --color=auto"

# Force a color shell prompt, even if an explicitly color-supported terminal (IE: xterm-256color) is not detected
system_bash_force_color_prompt: false

# String to put at the beginning of the bash prompt (no color)
system_bash_prompt_header: >-
  {{ org | default('') }}{{ '-' + env if env | default('') is truthy else '' }} ⮞ 

# String to put at the beginning of the bash prompt (with color)
system_bash_color_prompt_header: >-
  \e[3;1;35m{{ org | default('') }}{{ '-' + env if env | default('') is truthy else '' }}\e[0m\e[1;1;34m ⮞\e[0m 

# Main bash prompt (no color)
system_bash_prompt_string: >-
  \u@\h:\w\$ 

# Main bash prompt (with color)
system_bash_color_prompt_string: >-
  \[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ 

# Should existing user bashrc files be overwritten
#  - Set to false to prevent overwriting existing user bashrc files with the system default from /etc/skel/
#    If false, user bashrc files will be updated in place to source the system /etc/bashrc.d/ directory
system_bashrc_overwrite_existing: false

### }}}


### Shell Environment Variable Configuration ### {{{

# Name of the file in which the defined environment variables should be stored
#  - File will be stored in:
#    - [global] /etc/bashrc.d/{{ system_environment_filename }}.sh
#    - [user] ~/.bashrc.d/{{ system_environment_filename }}.sh
system_environment_filename: ansible_default_env

# Hide log output from tasks setting environment variables
#  - Set to true to avoid detailed task logging for environment variable setting tasks
#    - Useful to prevent exposing sensitive information such as secrets
system_environment_no_log: false

# Should any empty environment variables be purged from the system
#  - Only applies if one of the following is true --
#      - system_global_environment_vars: {}
#      - system_user_environment_vars: {}
#  - Set to true to remove the file matching <system_environment_filename>.sh
system_environment_purge_empty: false

# Environment variables that should be set for all users on the system
# - Each variable should be a key-value pair where the key is the variable name and the value is the value
system_global_environment_vars:
  # Set the default editor
  EDITOR: "vim"
  # Set the default pager
  PAGER: "less"
  # Set the default timezone
  TZ: "{{ system_timezone }}"
  # Set the default language
  LANG: "en_US.UTF-8"

# Dictionary of environment variables that should be set for specific users on the system
#  - Each user should be a key-value pair where the key is the username and the value is a dictionary of environment variables
#
#    For example -- to set the EDITOR variable for the root user:
#    system_user_environment_variables:
#      root:
#        EDITOR: "vim"
system_user_environment_vars: {}


### }}}

## }}}


## MOTD Configuration ## {{{
system_motd_banner: |
  \e[1;96m\e[48;5;232m
  ╔═══════════════════════════════════════════════════════════════════════════════════════╗
  ║                     .o.         .oooooo.   ooo        ooooo oooooooooooo              ║
  ║                    .888.       d8P'  `Y8b  `88.       .888' `888'     `8              ║
  ║                   .8"888.     888           888b     d'888   888                      ║
  ║   \    /\        .8' `888.    888           8 Y88. .P  888   888oooo8                 ║
  ║    )  ( ')      .88ooo8888.   888           8  `888'   888   888    "                 ║
  ║   (  /  )      .8'     `888.  `88b    ooo   8    Y     888   888       o              ║
  ║    \(__)║     o88o     o8888o  `Y8bood8P'  o8o        o888o o888ooooood8              ║
  ║                                                                                       ║
  ║                          Advanced Computer Mouse Endangerment                         ║
  ╚═══════════════════════════════════════════════════════════════════════════════════════╝
  \e[0m

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
    content: "\\e[1;31mWARNING:\\e[0m This host is managed by Ansible! Manual changes may revert automagically!"
    state: present

# List of filenames that should be removed if they're in the update-motd.d directory
# - Defaults to an internal list of known conflicting default files
system_motd_blacklist: "{{ __system_compat_motd_blacklist | default([]) }}"

# Title of 'status' section in the MOTD
system_motd_status_header: "Configuration Status:"

# Data that should be included in the 'status' section of the MOTD
#  - Store as a dictionary of key-value pairs, where the key is the title and the value is the data
#  - Updating these values will not trigger a 'changed' state in the playbook
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

# Timezone for the system
system_timezone: UTC

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

Dependent system packages for role operation are installed by the role when `system_packages_base: DEFAULT` is set.

If non-default base packages list is provided, additional dependencies may be required.

Example Playbook
----------------

```yaml
- name: Perform default system configuration
  hosts: all
  tasks:
    - name: Launch base system configuration
      ansible.builtin.include_role:
        name: system
```

```yaml
- name: Configure subset of system features 
  hosts: all
  tasks:
    - name: Configure system shell and MOTD
      vars:
        system_default: false
        system_enable_shell: true
        system_enable_MOTD: true
      ansible.builtin.include_role:
        name: system
```

License
-------

MIT

Author Information
------------------

- [syndr](http://github.com/syndr) 

