# Azure Hacks

## Virtual machine suicide

A machine should be able to [shut itself off and stop charging money](https://feedback.azure.com/forums/216843-virtual-machines/suggestions/6750431-allow-shutdown-from-vm-to-deallocated-state).  This is useful for the end of long-running, variable-length computation.  This repo is a kludge to get around that limitation.

We assume you are using [VM scalesets](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-overview).  To install `deallocate` and `delete` commands on your VMs, run
```bash
./vmss_setup.sh --resource-group mygroup --name myscaleset
```
It will:
1. Insecurely scrape SSH host keys and add them to your `~/.ssh/known_hosts`.  [There does not appear to be a secure way to do this.](https://feedback.azure.com/forums/34192--general-feedback/suggestions/8948203-display-ssh-host-key-fingerprints-for-linux-vm-s)
2. Copy your `~/.azure` to the machines so they have command line access.
3. Install delete and deallocate commands so you can run them inside the VM.
4. Print SSH commands to connect with.

For even more convenience, use `./vmss_create` as a drop-in replacement for `az vmss create`.  

### Requirements

- [GNU parallel](https://www.gnu.org/software/parallel/) installed on the client (though we could make a slower version without it).
- [az command line](https://github.com/Azure/azure-cli/) on the client and VM image.
- SSH keys working.
