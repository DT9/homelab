# Windows Golden Image Factory

This repository contains a production-ready pipeline for building a hardened Windows 10/11 Golden Image using Packer and GitHub Actions. It is designed for enterprise environments with strict security controls, but also includes considerations for personal use like gaming.

## Features

- **Automated Pipeline**: Builds are triggered automatically via GitHub Actions.
- **Infrastructure as Code**: Image configuration is defined in HCL with Packer.
- **Security Hardening**: Applies CIS Level 1 benchmarks to secure the OS.
- **Debloated**: Removes unnecessary pre-installed Windows apps.
- **Automated Validation**: Includes a post-build script to verify security settings.
- **GitOps Ready**: Modular, version-controlled, and CI/CD integrated.

## How It Works

1.  **Trigger**: The GitHub Actions workflow is triggered by a push to `main` or manually.
2.  **Runner**: A self-hosted Windows runner with Hyper-V enabled picks up the job.
3.  **Packer Init**: The workflow initializes Packer, downloading the required `hyperv` plugin.
4.  **Packer Build**: Packer creates a new Hyper-V VM from the specified Windows ISO.
5.  **Automated Installation**: An `Autounattend.xml` file completely automates the Windows setup process, including creating a temporary `packer` user.
6.  **Provisioning**: Packer connects to the VM using WinRM and executes a series of PowerShell scripts to:
    - Install updates, Chocolatey, and desired software.
    - Apply CIS security hardening settings.
    - Remove bloatware.
    - Run validation checks.
    - Clean up the system and run `Sysprep`.
7.  **Capture**: After Sysprep shuts down the VM, Packer captures the state of the virtual disk (`.vhdx`).
8.  **Artifact**: The GitHub Actions workflow uploads the final `.vhdx` file as a build artifact, ready for deployment.

## Prerequisites

1.  **Self-Hosted GitHub Runner**: You need a Windows machine with Hyper-V enabled, configured as a [self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners) for your repository.
2.  **Windows ISO**: A Windows 10/11 ISO file must be available on the runner machine. The path to this ISO is specified in the GitHub Actions workflow.
3.  **Execution Policy**: Ensure the PowerShell execution policy on the runner allows running scripts. You can set this with `Set-ExecutionPolicy RemoteSigned -Scope LocalMachine`.

## Setup and Configuration

1.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    ```

2.  **Configure GitHub Secrets and Variables**:
    - **`ADMIN_PASSWORD`** (Secret): The password for the temporary `packer` user. This password must **exactly match** the password specified in `http/Autounattend.xml`.
        - Go to `Repository Settings > Secrets and variables > Actions > New repository secret`.
    - **`ISO_PATH`** (Variable - Optional): The absolute path to the Windows ISO file on your runner. If not set, it defaults to `C:/ISOs/en-us_windows_10_enterprise_ltsc_2021_x64_dvd_b4b31a3a.iso`.
        - Go to `Repository Settings > Secrets and variables > Actions > New repository variable`.
    - **`ISO_CHECKSUM`** (Variable - Optional): The SHA256 checksum of your ISO file. It's highly recommended to update this to match your ISO to ensure integrity.

3.  **Update `Autounattend.xml`**:
    - Open `http/Autounattend.xml`.
    - Find all instances of `<Value>CHANGEME</Value>` and replace `CHANGEME` with the same strong password you set in the `ADMIN_PASSWORD` secret.

## Running the Pipeline

To start a build, you can either:
- **Push a change** to any of the `*.pkr.hcl`, `http/*`, or `scripts/*` files in the `main` branch.
- **Manually trigger a build**:
  1. Go to the **Actions** tab in your GitHub repository.
  2. Select the **Build Windows Golden Image** workflow.
  3. Click **Run workflow**, choose the branch, and confirm.

After the run is complete, you can download the `.vhdx` file from the **Artifacts** section of the workflow summary. 