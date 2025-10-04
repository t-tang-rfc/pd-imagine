``` header
@file: pd-imagine/README.txt
@date: [created: 2025-02-05, updated: 2025-09-02]
@author: [madpang, t-tang-rfc]
```
# pd-imagine

## Introduction

This is a Docker image providing an isolated dev. env., but at the same time supporting SSH/GPG agent forwarding.
It makes *in situ.* code committing and authoring easier.

It can either be launched via standard Docker commands or through the Visual Studio Code Dev Containers extension, while the latter one is the recommended way to use this image.

When used as a VS Code dev container, you get the following extra features:
1. SSH agent forwarding
2. GPG agent forwarding
3. Git credential sharing
4. Interactive Python Window
Those bonus features are applicable even when connecting to a remote server using *Remote SSH extension*.

Note, git credential sharing is handled by `credential.helper` supplied by VS Code Dev Containers extension.

## Usage

To use this Docker image as a dev container in VS Code:
1. `cd` into your <project-folder>
2. `git submodule add --branch main https://github.com/madpang/pd-imagine.git .devcontainer`
3. Build the Docker image by running `./build.sh` from the `.devcontainer` directory
4. Create a `devcontainer.json` file in your `.devcontainer` directory. You can either:
   - Create a symbolic link to one of the task-specific predefined configurations provided in this repository
   - Create your own custom configuration to suit your specific needs
5. Open the workspace folder in VS Code, via `code .`
6. Use VS Code command "Dev Containers: Reopen in Container" to start the container
@see: [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers).
If you do not want to embed this project as a submodule, you can also create a `.devcontainer` symbolic link to the `pd-imagine` folder.

NOTE, currently, if using "open folder in dev container" feature in VS Code, the container will NOT automatically stop when you close the connection.
You need to manually stop the container by executing `docker stop <container-id>` on the host machine.

## Guideline for contribution

1. Fork this repository
2. Create your feature or bugfix branch from the `develop` branch to address one of the issues in the `tickets.txt` file
3. Make your pull request to the `develop` branch

NOTE, issue tickets are published through the develop branch, one can file new issues through the issue tracker on the GitHub page.
