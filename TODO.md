# yggdrasil / An Arch Linux Distribution Framework

## Table of Contents
* [TODO list](#todo-list)
* [Details](#details)
* [Thoughts](#thoughts)

## TODO List
* Documentation
	- [x] Flesh out initial todo list
	- [x] License
	- [ ] History/purpose
	- [ ] Goal
	- [ ] Hardware
	- [ ] Decisions
	- [ ] Usage/adaptation
	- [ ] Contributions
* Planning
	- [ ] Required packages
	- [ ] Naming conventions/names
	- [ ] Software
	- [ ] Programming languages
	- [ ] Code styling
	- [ ] Plan/organize implementation
		- [ ] File templates
		- [ ] Package breakdown plan
- Implementation
	- [ ] TBD

## Details
Use a dependency tree to pull packages in. For example, the Laptop-specific package should contain on everything unique to the laptop, like power consumption packages and settings, and also depend on packages such as (exact specifications TBD):
	- Workstation package: all DM/WM and generic workstation packages/settings, plus
		- CPU package: CPU-specific microcode
		- Graphics package: Drivers and hardware acceleration
	- Base package: all packages/settings to all devices (shell, utilities, etc)

## Thoughts
- Do I want contributions? This will be customized for my system, but bugfixes or improvements on scripts might be desirable.
- Consider forking bigger/more useful scripts into their own repositories/packages
- Should base include CPU microcode or be suitable for a virtual machine/systemd-nspawn container?
