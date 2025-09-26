
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
  Each transcoding session generates a timestamped log file. Users can optionally specify a custom log directory.

- **Systemd Integration**  
  Runs as a persistent background service using `systemd`.

- **Uninstall Support**  
  Clean removal of all service components via a single `--uninstall` flag.

- **Cross-Distro Compatibility**  
  Supports `apt`, `dnf`, and `pacman` package managers.

  ⚠️ *Alpine support has been deprecated and will be handled in a separate script.*

---

## 📦 Requirements

The following packages are required and automatically installed via `requirements.sh`:

- `ffmpeg`
- `inotify-tools`

---

## 🛠 Installation

Run the `install.sh` script with the required options:

```bash
./install.sh -d /path/to/watch
```

### ⚙️ Optional Flags

| Flag            | Argument         | Description                                                  |
|-----------------|------------------|--------------------------------------------------------------|
| `-d`            | `/path/to/watch` | Directory to monitor for new video files                    |
| `-L`            | `/path/to/logs`  | Custom directory to store log files, optional                         |
| `--uninstall`   | *(none)*         | Removes the service and all associated files                |
| `--help`, `-h`  | *(none)*         | Displays usage information and exits                        |

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

## 🧊 Alpine Linux Support

Alpine support has been **removed** from the current version.  
A dedicated Alpine-compatible script will be released separately.

---

## 🗒️ Changelog

 **install.sh v1.5.2**
- Added moved_to support to detect same filesystem changes e.g. from one folder to the watched folder in the same drive.
- switched to --format '%w%f' for reliable path parsing
- Minor README and logging improvements

 **install.sh v1.5.2.1**
 - Retained moved_to event in inotifywait to support intra-filesystem file moves
 - All other changes from 1.5.2 (including README and systemd format fixes) have been reverted

---
## 📄 Versioning Summary

| Script Name       | Version | Notes                                 |
|------------------|---------|----------------------------------------|
| `install.sh`     | 1.5.2   | Systemd setup and teardown             |
| `transcode.sh`   | 8.2.3   | Transcoding with logging enhancements  |
| `requirements.sh`| 1.2.1   | Alpine support removed                 |

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

## 🤝 Contributing

Fork the project and build a better one, please, I beg you. I do NOT have the time or skill to maintain this project!

---

## 📜 License

This project is open-source and available under the [MIT License](LICENSE).

> This script was created in collaboration with Microsoft Copilot, an AI companion.  
> Copilot Version: August 2025  
> Copilot is licensed under the [Microsoft License Terms](https://aka.ms/copilotlicense).
