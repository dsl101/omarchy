# Customisation

Edited install/packaging/webapps.sh to remove bloat.
Added _scripts/bump-upstream.sh to automate tracking upstream releases
Added these notes for installation:
 1. Install base arch using recommended process (https://learn.omacom.io/2/the-omarchy-manual/96/manual-installation)
 2. Install customised omarchy:
```
curl -fsSL https://raw.githubusercontent.com/basecamp/omarchy/master/boot.sh | OMARCHY_REPO="dsl101/omarchy" bash
```
