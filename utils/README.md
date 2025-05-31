# Utility Scripts

This directory contains utility scripts that follow the "spilled coffee principle" - ensuring that anyone can quickly restore their environment after a system failure.

## Available Scripts

### install-java.sh

Installs Java and sets up necessary environment variables. Supports multiple platforms and Java versions.

```bash
# Install default Java version (17)
./install-java.sh

# Install specific Java version
./install-java.sh 11
```

Features:
- Detects operating system automatically
- Supports Debian, Fedora, Arch, and macOS
- Falls back to manual installation for unsupported systems
- Sets up JAVA_HOME and PATH environment variables
- Offers optional Clojure installation
- Provides educational information about the JVM

### install-clojure.sh

Installs Clojure and sets up the necessary environment.

```bash
./install-clojure.sh
```

Features:
- Automatically checks for and installs Java dependency if needed
- Detects operating system and uses appropriate installation method
- Supports Debian, Fedora, Arch, and macOS
- Falls back to manual installation for unsupported systems
- Provides educational information about Clojure and REPL-driven development

### install-go.sh

Installs Go and sets up the Go workspace.

```bash
./install-go.sh
```

Features:
- Detects operating system and architecture
- Attempts to install using system package manager
- Falls back to manual installation if needed
- Sets up GOPATH and other environment variables

### fix-npm-nvm-conflict.sh

Resolves conflicts between npm and nvm installations.

```bash
./fix-npm-nvm-conflict.sh
```

## Adding New Scripts

When adding new utility scripts, please follow these guidelines:

1. **Naming Convention**: Use `install-{tool}.sh` for installation scripts
2. **Error Handling**: Include proper error handling and status messages
3. **Cross-Platform**: Support multiple platforms when possible
4. **Documentation**: Add usage instructions in the script header
5. **Environment Variables**: Set up necessary environment variables
6. **Idempotence**: Scripts should be safe to run multiple times
7. **Educational Content**: Include information about the tool being installed

## The Spilled Coffee Principle

The "spilled coffee principle" states that anyone should be able to destroy their machine and be fully operational again that afternoon. These utility scripts help achieve this by automating the setup of various development tools and environments.
