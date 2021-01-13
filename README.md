# Deploy Algo Wireguard VPN Github Action

This action installs Algo Wiregard VPN on the target server specified. It
assumes an Ubuntu server.

## Inputs

### `ssh-private-key`

**Required** Private ssh key. The public key must be present in ~/.ssh/authorized_keys on the target server.

### `public-ip` 

**Required** Public IP address of the target server


## Example usage

```
steps:
  - uses: actions/checkout@v2
    with:
        fetch-depth: 0
  - uses: chrisjsimpson/deploy-wireguard-algo-vpn-action@v1
    with:
        ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
        public-ip: ${{ secrets.PUBLIC_IP }}
```
