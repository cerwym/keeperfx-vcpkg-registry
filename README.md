# keeperfx-vcpkg-registry

A private vcpkg registry for KeeperFX ports not available in the upstream catalog.

## Ports

| Port | Version | Upstream |
|---|---|---|
| astronomy | 2.1.19 | https://github.com/cosinekitty/astronomy |
| libnatpmp | 20231022 | https://github.com/miniupnp/libnatpmp |

## Setup

Add to your project's `vcpkg-configuration.json`:

```json
{
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/dkfans/vcpkg-registry",
      "baseline": "<SHA of latest commit on this repo>",
      "packages": ["astronomy", "libnatpmp"]
    }
  ]
}
```

## Updating versions

After editing a port:
```sh
vcpkg x-add-version --all --overwrite-version
git add versions/
git commit -m "chore: bump port versions"
```
