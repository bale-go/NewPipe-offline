# NewPipe Offline Song Repository Builder

This repository provides a guide and scripts for building your own offline repository of your favorite songs based on your NewPipe listening statistics. With this repository, you can easily collect the songs you enjoy the most and create a personalized offline collection.

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction

Have you ever wanted to have your favorite songs accessible offline, without relying on an internet connection or music streaming services? This repository aims to help you create an offline collection of your most loved songs based on your listening statistics.

The process involves retrieving your listening history from NewPipe, extracting the relevant song information, and then using those details to download the audio files in a local repository.

## Prerequisites

To use the scripts provided in this repository, you'll need the following:

- Python 3.7 or higher
- Python packages: `pandas`, `os`, `argparse`
- sqlite3
- Access to your listening statistics from NewPipe
- (optional) If you do not want large differences between the perceived loudness of tracks: `ffmpeg` and `ffmpeg-normalize`

## Getting Started

To get started, follow these steps:

1. Clone this repository to your local machine using the following command:
   ```bash
   git clone https://github.com/bale-go/NewPipe-offline.git
   ```
2. Install the required Python packages using `pip`:
   ```bash
   pip install pandas
   ```
3. Access your NewPipe listening history on your phone: NewPipe -> Settings -> Content -> Export database
4. Change to the directory with the scripts:
   ```bash
   cd NewPipe-offline
   ```
5. Copy from the phone and extract NewPipeData-#.zip to the NewPipe-offline folder.
6. Convert newpipe.db to csv files (requires sqlite3: sudo apt install sqlite3):
   ```bash
   bash sqlite2csv.sh newpipe.db 
   ```
7. Downoad yt-dlp, which is a youtube-dl fork based on the now inactive youtube-dlc.
   ```bash
   sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
   sudo chmod a+rx /usr/local/bin/yt-dlp 
   ```


## Usage

The repository provides a command-line interface (CLI) for easy interaction with the scripts. The main script is `repository_builder.py`, which handles the process of building the offline repository.

```
usage: python repository_builder.py [-h] [-rc REPEAT_COUNT] [-d DURATION]
arguments:
  -h, --help            show this help message and exit
  -rc REPEAT_COUNT, --repeat_count REPEAT_COUNT 
                        the track was streamed at least 'repeat_count' times                        
  -d DURATION, --duration DURATION  
                        the track is at most 'duration' seconds long
```
                        

To download the songs that you streamed at least 6 times and is at most 900 s long, run the following command:

```bash
python repository_builder.py -rc 6 -d 900
```

The script will download the audio files for your favorite songs in opus format.
Opus is a highly versatile and advanced audio codec format known for its exceptional compression rate and quality. Developed by the Internet Engineering Task Force (IETF), Opus offers impressive performance across a wide range of applications, including music streaming, VoIP, and video conferencing. What sets Opus apart is its ability to achieve outstanding compression without significant loss of audio quality. By leveraging innovative techniques like variable bitrate encoding and adaptive streaming, Opus delivers superior efficiency compared to other lossy formats. As a result, it has gained recognition as the leading audio format for achieving the best compression rate while maintaining excellent sound fidelity.

## (Optional) Adjusting the perceived loudness of tracks:

ReplayGain is a valuable audio processing technique designed to address the inconsistent volume levels of individual tracks that often plague our music libraries. It offers several notable advantages. Firstly, ReplayGain enables the normalization of audio tracks, ensuring they play back at a consistent volume level. This eliminates the need for constant manual volume adjustments, creating a seamless listening experience across different songs and albums. Secondly, it preserves the original dynamic range of the music, meaning the soft and loud parts of a song are maintained without distortion or compression. This allows for a more authentic representation of the artist's intended sound, enhancing the overall listening pleasure.

To normalize tracks, follow these steps:
1. Install the required Python package using `pip`:
   ```bash
   pip install ffmpeg-normalize
   ```
2. You can use parallel and ffmpeg-normalize (sudo apt install parallel ffmpeg) to normalize tracks. Opus at 128 KB/s (VBR) is pretty much transparent, meaning that it is pretty much indistinguishable from the lossless format.
   ```bash
   parallel ffmpeg-normalize {} --keep-loudness-range-target -t -13 -c:a libopus -b:a 128k -o {} -f ::: ./*.opus
   ```



## Contributing

Contributions are welcome! If you want to contribute to this project, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Implement your changes.
4. Commit your changes and push them to your fork.
5. Submit a pull request describing your changes.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE). Feel free to modify and distribute the code as needed.
