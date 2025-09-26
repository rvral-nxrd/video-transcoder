
# 🎬 Transcode Service

 I designed this script specifically for `Davinci Resolve` free users on Linux, since it does not support a lot of codecs. I used codecs I know work without issue, stay close to the original file's quality and file size. 
 It watches a specified directory for new video files, transcodes them using `ffmpeg`, and organizes the output by creation date.

---

## ✨ Features

- **Automated Transcoding**  
  Monitors a directory using `inotifywait` and triggers transcoding on file write completion.

- **Date-Based Organization**  
  Output files are stored in subfolders named after the original file's creation date.  

- **Custom Logging**  
  Each transcoding session generates a timestamped log file in `/var/log/transcode`. Users can optionally specify a custom log directory.

- **Systemd Integration**  
  Runs as a persistent background service using `systemd`.

- **Uninstall Support**  
  Clean removal of all service components via a single `--uninstall` flag.

- **Failure Handling**
  Failed transcodes are moved to `failed` with a `.fail` sidecar file and a running log.

- **Cross-Distro Compatibility**  
  Supports `apt`, `dnf`, and `pacman` package managers.

  ⚠️ *Alpine support has been deprecated and will be handled in a separate script.*

---

## 📦 Requirements

The following packages are required and automatically installed via `requirements.sh`:

- `ffmpeg`
- `inotify-tools`
- `cron`

---

## 📂 Directory Structure  

```bash
/watch/                    # Watched directory
  ├── .cache/              # Temporary transcoding output
  ├── failed/              # Quarantine for failed files
  ├── YYYY-MM-DD/          # Dated output folders for successful transcodes
```

---
## 🛠 Installation

Run the `install.sh` script with the required options:

```bash
./install.sh -d /path/to/watch
```
This will install:
- `ffmpeg`
- `inotify-tools`
- `cron` (or `cronie` depending on distro)
- Create a `systemd` service to monitor the folder and a `cron` job that runs everyday at 3am to clean up `.cache`

---

### ⚙️ Flags

| Flag            | Argument         | Description                                                  |
|-----------------|------------------|--------------------------------------------------------------|
| `-d`            | `/path/to/watch` | Directory to monitor for new video files (mandatory)         |
| `-L`            | `/path/to/logs`  | Custom directory to store log files, (optional)              |
| `--uninstall`   | *(none)*         | Removes the service and all associated files                 |
| `--help`, `-h`  | *(none)*         | Displays usage information and exits                         |

---

## 🧪 Example Workflow

```bash
# Step 1: Install and start the service
./install.sh -d /home/siyamthanda/videos

# Step 2: Drop a video file into the watched directory
mv sample.mp4 /home/siyamthanda/videos/

# Step 3: View logs
cat /var/log/transcode/20250829_173100.log
```

---

## 🎞 Transcoding Logic

The `transcode.sh` script handles the actual conversion:

- **Input**: Any video file detected in the watched directory  
- **Output**: `.mov` format using the `mpeg-4` video codec and `pcm_s16le` audio codec 
- **Post-process**: Deletes original file after successful transcoding  
- **Logging**: Outputs to `/var/log/transcode/[timestamp].log` or custom path via `-L`

---

## 📁 Logging Example

```bash
./transcode.sh -L /home/siyamthanda/logs /videos/input.mp4
```

Creates a log file like:

```
/home/siyamthanda/logs/20250829_173100.log
```

---


## 🔧 Uninstallation

To remove the service and clean up all files:

```bash
./install.sh --uninstall
```

This will:
- Stop and disable the systemd service
- Remove service files and scripts
- Delete log and script directories

---


## 📄 Version Summary

| Script Name      | Version | Notes                                                         |
|------------------|---------|---------------------------------------------------------------|
| `install.sh`     | 1.5.3   | Script moved to `/opt`, cron cleanup                          |
| `transcode.sh`   | 8.3.2   | Lazy folder creation + quarantine system for failed transcodes|
| `requirements.sh`| 1.2.3   | Efficient package install + cron support                      |

---

## 🗒️ Changelog

 **install.sh v1.5.3**
 - Retained moved_to event in inotifywait to support intra-filesystem file moves.
 - All other changes from 1.5.2 have been partially reverted.
 - Script folder changed to `/opt/auto-trranscode` to keep in line with traditional `unix` folder management.
 - Creates a `cron` job to cleanup the `.cache` folder every morning at 3am.
 ```bash
 0 3 * * * find /landing/.cache -type f -mtime +1 -delete
```
 
 **transcode.sh v8.3.2**

 - A quarantine system for failed transcodes, including a file.extention.fail `sidecar` file and a running `log` file for all failed transcodes in format:  
 ```bash
 2025-09-26 17:52 - video1.mp4 - invalid input data
 ```
 - Lazy folder creation to avoid creating empty destination folders if a transcode fails.

 **requirements.sh v1.2.3**
  - Checks for an installs `cron` or `cronie`, depending on `distro`, if it is not installed already.
---

## 🧰 Coming Soon! ##

- Optional flags for dry-run, quarantine toggle and metadata based dating.
- Alpine support.
- Docker support.
- An interactive dialog for `tui` installation.


## 🤝 Contributing

Fork the project and build a better one, please, I beg you. I do NOT have the time or skill to maintain this project!

---

## 📜 License

This project is open-source and available under the [MIT License](LICENSE).

> This script was created in collaboration with Microsoft Copilot, an AI companion.  
> Copilot Version: August 2025  
> Copilot is licensed under the [Microsoft License Terms](https://aka.ms/copilotlicense).
