# Red Hat Certified Engineer (RHCE) exam

Online version of the objectives for the EX294 exam can be found in this [link](https://www.redhat.com/en/services/training/ex294-red-hat-certified-engineer-rhce-exam-red-hat-enterprise-linux-8?section=Objectives).

[//]: # (During the training preparations, I've identified two basic workflows when working with Ansible. A detailed diagram for such workflows can be found attached below.)

[//]: # (![Ansible Development Workflow]&#40;ansible-development-workflow.jpg&#41;)

[//]: # (<div style="text-align: center"> Figure 1: Generic Ansible Workflow for developing Playbooks. </div>)

[//]: # ()
[//]: # (![Ansible Execution Workflow]&#40;ansible-execution-workflow.jpg&#41;)

[//]: # (<div style="text-align: center"> Figure 2: Generic Ansible Workflow for executing Playbooks. </div>)

## Study points for the (EX294) exam

As an RHCE exam candidate, you should be able to handle all responsibilities expected of a Red Hat Certified System Administrator, including these tasks.

### Be able to perform all tasks expected of a Red Hat Certified System Administrator

- Understand and use essential tools
- Operate running systems
- Configure local storage
- Create and configure file systems
- Deploy, configure, and maintain systems
- Manage users and groups
- Manage security

### Understand core components of Ansible

- Inventories

- Variables
> Currently, there are 22 different places for defining Ansible variables. Depending on the place where the variable is defined, it may have more precedence or not. See [documentation](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#understanding-variable-precedence) for more details.

- Facts
> Facts are variables that are automatically discovered by Ansible from a managed host.

- Blocks

- Plays
> A common practice when developing playbooks is to use independent plays for configuration actions, and then other plays for testing/validating that first configuration play were properly applied to the system.

- Playbooks
```shell
# 1) Syntax verification
ansible-playbook --syntax-check <playbook.yml>

# 2) Running Playbooks
ansible-playbook <playbook.yml>

# 3) Executing a Dry Run (not supported by all modules)
ansible-playbook -C <playbook.yml>
```

- Roles

- Configuration files
- Use provided documentation to look up specific information about Ansible modules and commands

- Handlers
> Handlers are meant to perform an extra action when a task makes a change (using the `notify` keyword) to a managed 
> host. They always run at the end of the play's tasks, and should not be used as a replacement for normal tasks.

- [Plugins](https://docs.ansible.com/ansible/latest/plugins/plugins.html)
> Plugins are pieces of code that augment Ansible’s core functionality. Ansible ships with a number of handy plugins, 
> and uses a plugin architecture to enable a rich, flexible and expandable feature set.

- Modules

- Filters


### Install and configure an Ansible Controller node

- [Optional] Getting comfortable with the terminal
```shell
# 1) install bash-completion, vim-enhanced
dnf install bash-completion vim-enhanced tmux -y

# 2) configure vim for ansible
cat << EOF > ~/.vimrc
autocmd FileType yaml colo desert
autocmd FileType yaml setlocal ai ts=2 sw=2 et nu cuc
EOF
```

- Install required packages
```shell
# 1) check if ansible is installed
rpm -q ansible

# 2) check available repos for ansible
dnf repolist all | grep ansible

# 3) enable repo for ansible
dnf config-manager --enable <ansible-2-for-rhel-8-x86_64-rpms>

# 4) install ansible
dnf install ansible -y
```

- Create a configuration file
```shell
# 1) check config file used by Ansible Controller
ansible --version
ansible --list-hosts '*' -v

# 2) check ansible.cfg sample values
less /etc/ansible/ansible.cfg

# 3) [Optional] Configuration File Precedence
0. env | grep ANSIBLE_CONFIG  # overwrites all directories below
1. ./ansible.cfg              # (recommended) ansible's working directory 
2. ~/.ansible.cfg             # user's personal home directory
3. /etc/ansible/ansible.cfg   # system's global configuration directory 
```
> If not of the above directories has a configuration *.cfg file, then Ansible will use its predefined defaults.

- Create a static host inventory file
```shell
# advanced query for large inventories
ansible -i <path/to/inventory> --list-hosts '*'   # using patterns for hosts/groups

# simple query for small inventories
ansible-inventory -i <path/to/inventory> --list
```

- Create and use static inventories to define groups of hosts
```shell
# grouping by host's name
[first_four]
ansible[0:3].rhcx.box

# group of groups
[all:children]
first_four
second_four

# define group vars
[all:vars]
halon_system_timeout=30
self_destruct_countdown=60
```
> Organizing host and group variables in files can be very useful to keep your variables organized when a single file 
> gets too big, or when you want to use Ansible Vault on some group variables.

- Manage parallelism

The parallelism in Ansible can be managed by configuring the [serial](https://docs.ansible.com/ansible/latest/user_guide/playbooks_strategies.html#rolling-update-batch-size) and [fork](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-forks) parameters.
In a nutshell:
  - `serial` controls the number of managed hosts where a playbook is executed. By default, Ansible runs in parallel against all the hosts in the pattern you set in the `hosts:` field of each play.
  - `forks` controls the number of managed hosts where a task inside a playbook is executed. Must be lower than the serial setting to have an effect.
  - [optional] `throttle` limits the number of workers for a particular task. To have an effect, your throttle setting must be lower than your forks or serial setting if you are using them together.

### Configure Ansible managed nodes

- Create and distribute SSH keys to managed nodes
```shell
# generate ssk keys
ssh-keygen

# copy ssh keys to managed hosts
ssh-copy-id <user>@<managed-host-ip>
ansible -m authorized_key -a "user=automation state=present key={{ lookup('file','~/.ssh/id_rsa.pub') }}" all
```

- Configure privilege escalation on managed nodes
```shell
grep "privilege_escalation" -A5 /etc/ansible/ansible.cfg >> ansible.cfg
[privilege_escalation]
become=True
become_method=sudo
become_user=root
become_ask_pass=False
```

- Validate a working configuration using ad hoc Ansible commands
```shell
# check reachability to managed nodes
ansible -m ping all

# create <user> in managed nodes
ansible -a "useradd <user> -m -p $(openssl passwd -1 <password>)" all
```

ansible -m user -a "name=automation state=present password={{ 'devops' | password_hash('sha512') }}" -u root all

ansible -m authorized_key -a "user=automation state=present key={{ lookup('file','~/.ssh/id_rsa.pub') }}" -u root all

ansible -m copy -a "dest='/etc/sudoers.d/automation' content='automation ALL=(ALL) NOPASSWD:ALL'" -u root all


### Script administration tasks

- Create simple shell scripts
- Create simple shell scripts that run ad hoc Ansible commands

### Create Ansible plays and playbooks

- Know how to work with commonly used Ansible modules
```shell
# 1) list all available modules on control node
ansible-doc -l

# 2) show documentation for module <name-here>
ansible-doc <name-here>

# 3) show example output for module fields
ansible-doc -s <name-here>  >>  <playbook.yml>

# 4) list all available lookup plugins 
ansible-doc -t lookup -l
```

- Use variables to retrieve the results of running a command
- Use conditionals to control play execution
- Configure error handling
- Create playbooks to configure systems to a specified state

### Use Ansible modules for system administration tasks that work with

- Software packages and repositories
- Services
- Firewall rules
- File systems
- Storage devices
- File content
- Archiving
- Scheduled tasks
- Security
- Users and groups

### Work with roles

- Create roles
```
# 1) initialize a role
ansible-galaxy init <author.role-name>

# 2) inspect created skeleton
tree leo8s.myrole/

leo8s.myrole/
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── README.md
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

8 directories, 8 files
```

- Download roles from an Ansible Galaxy and use them
```shell
# 1) list installed roles
ansible-galaxy list

# 2) search roles using galaxy
ansible-galaxy search <role-name> --platforms <EL|Ubuntu> --galaxy-tags <tag> --author <author>

# 3) install roles using galaxy
ansible-galaxy install <role-name> -p <path-where-role-will-be-installed>

# 4) remove roles using galaxy
ansible-galaxy remove <role-name>
```

### Use advanced Ansible features

- Create and use templates to create customized configuration files
- Use Ansible Vault in playbooks to protect sensitive data
```shell
# 1) view the vault secret
ansible-vault view <secret.yml>

# 2) edit the vault secret
ansible-vault edit <secret.yml>

# NOTE: The edit subcommand always rewrites the file, so you should only use it when making changes.

# 3) encrypt an existing file
ansible-vault encrypt <secret.yml>

# 4) decrypt an existing file
ansible-vault decrypt <secret.yml> --output=<secret-decrypted.yml>
```

> Recommended Practices for Variable File Management is to store sensitive variables and all other variables in separate 
> files. The files containing sensitive variables can then be protected with the ansible-vault command.

```shell
# 1) execute playbook with one secret
ansible-playbook --vault-id @prompt <playbook.yml>

# 2) execute playbook with multiple secrets
ansible-playbook --vault-id one@prompt --vault-id two@prompt <playbook.yml>
```

> As with all Red Hat performance-based exams, configurations must persist after reboot without intervention.
