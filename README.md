<!-- TOC start (generated with https://github.com/derlin/bitdowntoc) -->

- [📸 Media Renamer - EXIF-Based Photo & Video Organizer](#-media-renamer-exif-based-photo-video-organizer)
   * [🎯 Why This Project Exists](#-why-this-project-exists)
   * [✨ Key Features](#-key-features)
   * [📋 Requirements](#-requirements)
   * [⚠️ Compatibility tested](#%EF%B8%8F-compatibility-tested)
      + [MacOS](#macos)
      + [Linux (Ubuntu, Debian) or CentOS/Fedora](#linux-ubuntu-debian-or-centosfedora)
      + [Installing ExifTool](#installing-exiftool)
   * [🚀 Installation](#-installation)
   * [📖 Usage](#-usage)
      + [Basic Syntax](#basic-syntax)
      + [Essential Parameters](#essential-parameters)
      + [Naming Customization](#naming-customization)
      + [File Type Selection](#file-type-selection)
      + [Operation Modes](#operation-modes)
         - [rename mode](#rename-mode)
         - [output directory](#output-directory)
      + [Advanced Options](#advanced-options)
         - [use_date_name](#use_date_name)
         - [ignore directories](#ignore-directories)
         - [debug mode](#debug-mode)
   * [🧪 Example of use with the `sandbox` directory](#-example-of-use-with-the-sandbox-directory)
      + [📁 Example structure](#-example-structure)
      + [▶️ Example 1: Renaming generic photos](#%EF%B8%8F-example-1-renaming-generic-photos)
      + [▶️ Example 2: renaming photos with a WhatsApp-style prefix](#%EF%B8%8F-example-2-renaming-photos-with-a-whatsapp-style-prefix)
   * [💡 Common Use Cases](#-common-use-cases)
      + [Organizing Android Camera Photos](#organizing-android-camera-photos)
      + [Processing WhatsApp Images with Prefix](#processing-whatsapp-images-with-prefix)
      + [Fast In-Place Rename (Use with Caution)](#fast-in-place-rename-use-with-caution)
      + [Processing Only Specific File Types](#processing-only-specific-file-types)
      + [Processing HEIC and RAW Formats from iPhone](#processing-heic-and-raw-formats-from-iphone)
   * [📁 Output Format](#-output-format)
      + [Example Transformations](#example-transformations)
   * [🔍 How It Works](#-how-it-works)
   * [🛡️ Safety Features](#-safety-features)
   * [⚠️ Important Warnings](#%EF%B8%8F-important-warnings)
   * [🐛 Troubleshooting](#-troubleshooting)
   * [🤝 Contributing](#-contributing)
   * [📄 License](#-license)
   * [🙏 Acknowledgments](#-acknowledgments)
   * [📞 Support](#-support)

<!-- TOC end -->

# 📸 Media Renamer: EXIF-based photo and video organizer

English | [Español](README.es.md)

A Bash script for batch renaming photos and videos using the dates from their EXIF metadata.
It was born out of the need to solve the common problem of having multiple backups with the same photos under different names, which complicates organization and duplicate removal.

The project came about after years of trying to consolidate family photos from different phones, cloud services, and backups. The frustration of finding the same image five times with five different names led to the creation of a tool that automates this process in a consistent way.

> 💬 **Author's note**  
> My knowledge of Bash is limited, and I have tried to keep the code as clear and understandable as possible.  
> Even so, it may contain errors or parts that could be improved.  
> Suggestions and pull requests that help improve the clarity or reliability of the script are welcome.

## 🎯 Why This Project Exists

When you manage multiple photo backups from different sources like Android phones, iPhones, WhatsApp, Google Photos, or cloud storage services, you often end up with the same photo saved under different names. For example, a single vacation photo might appear as `IMG_1234.jpg` in one backup, `20230814_153045.jpg` in another, and `IMG-20230814-WA0023.jpg` in a WhatsApp folder.

This script solves that problem by renaming all your media files using a consistent format based on their original creation date stored in EXIF metadata. Once renamed, identical photos will have the same filename regardless of their source, making it trivial to identify and remove duplicates using standard deduplication tools.

The script is particularly useful for scenarios like consolidating years of photos from multiple devices, organizing family photo collections, or preparing media libraries for long-term archival storage.

## ✨ Key Features

**Intelligent date detection** means the script reads EXIF DateTimeOriginal metadata to determine when each photo or video was actually taken, not when it was last modified or copied. This ensures your files are renamed based on their true creation moment.

**Filename date priority** provides a safety mechanism where if the script detects a date pattern in the existing filename that differs significantly from the EXIF data (more than 180 days difference), it assumes the filename is more reliable and updates the EXIF metadata accordingly. This handles cases where EXIF data might be corrupted or missing.

**Safe operation modes** give you two ways to work: a copy mode that preserves your original files untouched while creating renamed copies in a separate directory, and an in-place rename mode for when you're confident and want faster processing without duplicating data.

**Customizable naming patterns** allow you to add prefixes to distinguish sources (like "WA_" for WhatsApp photos) and suffixes for categorization, giving you complete control over your naming convention while maintaining the timestamp-based core structure.

**Automatic panorama detection** recognizes MPO files (the format used for 3D panoramic photos on some devices) and automatically adds a "_PANO" suffix to help you identify these special files in your collection.

**Selective directory processing** means you can target specific folder names within your backup structure (like "DCIM" for camera photos or "WhatsApp" for messaging app media) while automatically ignoring output directories and other specified folders to prevent recursive processing issues.

## 📋 Requirements

Before using this script, you need to ensure your system has the necessary tools installed. The script requires Bash version 3.2 or higher, which is standard on macOS and most Linux distributions. The only external dependency is ExifTool, a powerful command-line application for reading and writing EXIF metadata.

## ⚠️ Compatibility tested
### MacOS
Tested on **macOS 14.6.1 (Apple Silicon)** using the [`exiftool`](https://exiftool.org/) tool.  
Verified with both local files on SSD and files on an SMB network drive connected from a **Windows 10** computer on the local network.  

### Linux (Ubuntu, Debian) or CentOS/Fedora
Operation has not been verified on **Linux**, **CentOS**, or other operating systems, so additional adjustments may be required (e.g., paths, permissions, or differences in command output).

### Installing ExifTool

On macOS using Homebrew, you can install ExifTool with a single command:

```bash
brew install exiftool
```

On Ubuntu or Debian-based Linux systems, the installation is equally straightforward:

```bash
sudo apt-get install libimage-exiftool-perl
```

On Fedora, RHEL, or CentOS systems, use the following command:

```bash
sudo dnf install perl-Image-ExifTool
```

After installation, you can verify that ExifTool is properly installed by checking its version:

```bash
exiftool -ver
```

This should display a version number, confirming that the tool is ready to use.

## 🚀 Installation

Getting started with the Media Renamer is simple. First, clone the repository to your local machine:

```bash
git clone https://github.com/hunzaGit/rename-files-with-exif.git
cd rename-files-with-exif
```

Next, make the script executable so you can run it directly:

```bash
chmod +x rename_files.sh
```

That's all you need to do. The script is now ready to use and doesn't require any compilation or additional configuration.

## 📖 Usage

The script follows a straightforward command-line interface pattern where you specify a source directory and optional parameters to control its behavior. At its most basic, you need to tell the script where your photos are located.

### Basic Syntax

```bash
./rename_files.sh --source <directory> [options]
```

### Essential Parameters

The **source directory** parameter is the only required argument and tells the script where to start looking for your media files. This should be the root directory containing your backups or photo collections:

```bash
--source <path>  or  -s <path>
```

The **target directory** parameter specifies which subdirectory names to search for within your source. This is useful when your backups have a consistent structure. For example, Android backups typically store camera photos in folders named "DCIM", while WhatsApp images are in "WhatsApp" folders:

```bash
--target <name>  or  -t <name>
```

The default value is "DCIM", which matches the standard camera folder name used by Android devices and many digital cameras.

### Naming Customization

The **prefix** parameter adds text to the beginning of renamed files, which is helpful for identifying the source of photos. For instance, you might use "WA" for WhatsApp photos or "IPHONE" for iPhone backups:

```bash
--prefix <text>  or  -p <text>
```

A photo taken on August 14, 2023, at 3:45 PM with prefix "WA" would become `WA_20230814_154500.jpg`.

The **suffix** parameter adds text to the end of the filename (before the extension), useful for additional categorization:

```bash
--suffix <text>
```

Using suffix "backup" would transform the same photo into `20230814_154500_backup.jpg`.

### File Type Selection

The **extensions** parameter controls which file types to process. By default, the script handles common photo formats (JPG, JPEG, PNG, HEIC) and video formats (MP4, MOV, 3GP), plus MPO for panoramas:

```bash
--ext "<extensions>"  or  -e "<extensions>"
```

For example, to process only JPG and MP4 files, you would use `--ext "jpg mp4"`.

### Operation Modes
#### rename mode
The **rename mode** parameter determines whether the script modifies original files or creates copies. This is one of the most important safety features:

```bash
--rename <true|false>  or  -r <true|false>
```

When set to false (the default and recommended for first-time use), the script copies files to a new directory while renaming them, leaving your originals completely untouched. When set to true, it renames files in place, which is faster and doesn't use extra disk space but permanently modifies your original files.

#### output directory
The **output directory** parameter specifies where renamed copies should be placed when rename mode is false:

```bash
--output <directory>  or  -o <directory>
```

The default is "renamed", which creates a subdirectory next to each processed file.

### Advanced Options
#### use_date_name
The **use date name** parameter controls whether the script should trust dates found in existing filenames over EXIF data when there's a significant discrepancy:

```bash
--use_date_name <true|false>  or  -dn <true|false>
```

This defaults to true, meaning if a filename contains a date that differs from the EXIF date by more than 180 days, the filename's date is considered more reliable and the EXIF data will be updated to match it.

I found it particularly useful in a WhatsApp backup, where the file names had the actual date and the EXIF data was incorrect. In this case, the image time is lost but the original date is retained.

> ⚠️ **Experimental option**:
> This feature is still experimental and may not work consistently in all cases.
> It is recommended to use it only for testing purposes or when the file names are trusted.

#### ignore directories
The **ignore directories** parameter lets you specify folder names that should be skipped during processing:

```bash
--ignore <dir1,dir2,dir3>  or  -i <dir1,dir2,dir3>
```

Directories are specified as a comma-separated list without spaces. The output directory is automatically added to this list to prevent processing the same files repeatedly.

#### debug mode

The **debug mode** parameter enables verbose logging that shows exactly what the script is doing at each step:

```bash
--debug <true|false>  or  -d <true|false>
```

This is incredibly useful when you first start using the script or when troubleshooting issues.


## 🧪 Example of use with the `sandbox` directory

The repository includes a `sandbox/` directory with examples ready to test the script's functionality without using your own photos.

### 📁 Example structure
```
sandbox/
├── photos/
│ ├── pexels-francesco-ungaro-2325447.jpg
│ ├── pexels-... (other example images)
│ └── ...
└── WhatsApp/
  └── Media/
    └── WhatsApp Images/
      └── pexels-mastercowley-1128797.jpg
```

The images used are from [Pexels](https://www.pexels.com/), under a free license, and are included for demonstration purposes only:

- [Photo by Francesco Ungaro on Pexels](https://www.pexels.com/photo/hot-air-balloon-2325447/)  
- [Photo by Philippe Donn on Pexels](https://www.pexels.com/photo/brown-hummingbird-selective-focus-photography-1133957/)  
- [Photo by Pixabay on Pexels](https://www.pexels.com/photo/green-leafed-tree-beside-body-of-water-during-daytime-158063/)  
- [Photo by Nathan Cowley on Pexels](https://www.pexels.com/photo/pink-flowers-photography-1128797/)  

---


### ▶️ Example 1: Renaming generic photos

Run the script from the project root:

```bash
./rename_files.sh \
  --source ./sandbox \
  --target “photos” \
  --rename false \
  --output “renamed” \
  --debug true
```

This will process the photos in the `sandbox/photos` directory and generate the renamed (or simulated, depending on --rename) results in `sandbox/photos/renamed`.

### ▶️ Example 2: renaming photos with a WhatsApp-style prefix

Run the script from the root of the project:

```bash
./rename_files.sh \
  --source ./sandbox \
  --target “WhatsApp” \
  --prefix “WA” \
  --rename false \
  --output “renamed” \
  --ignore “old,temp” \
  --debug true
```

This command processes the images in the `sandbox/WhatsApp/Media/WhatsApp Images/` directory, applying the WA prefix to the generated names and skipping directories containing old or temp.


> 💡 Note:
> The above examples run in --debug true mode, which allows you to see the simulated operations without actually modifying the files.
> Set --rename true if you want to apply the changes to disk.




## 💡 Common Use Cases

Let me walk you through several real-world scenarios where this script shines, showing you the exact commands you would use and what to expect.

### Organizing Android Camera Photos

When you have Android phone backups and want to rename all camera photos without modifying the originals, this is the safest approach to start with:

```bash
./rename_files.sh \
  --source "/Users/me/PhoneBackups" \
  --target "DCIM" \
  --rename false \
  --output "renamed" \
  --debug true
```

This command searches through your backups for any folder named "DCIM", processes all supported image and video formats, creates renamed copies in "renamed" subdirectories, and shows you detailed progress information. Your original files remain completely unchanged, so you can verify the results before deciding to use the renamed versions.

### Processing WhatsApp Images with Prefix

WhatsApp images often have confusing names, and adding a prefix helps you identify them later when consolidating multiple sources:

```bash
./rename_files.sh \
  --source "/Users/me/Backups" \
  --target "WhatsApp" \
  --prefix "WA" \
  --rename false \
  --output "renamed" \
  --ignore "old,temp" \
  --debug true
```

This processes any folder named "WhatsApp", adds "WA_" to the beginning of each renamed file, and ignores any folders named "old" or "temp". The result is files like `WA_20230814_154500.jpg` that are clearly marked as WhatsApp originals.

### Fast In-Place Rename (Use with Caution)
> ⚠️ **Use with Caution**:

Once you've tested the script and are confident in the results, you can use in-place renaming for speed:

```bash
./rename_files.sh \
  --source "/Users/me/PhotoArchive" \
  --target "DCIM" \
  --rename true \
  --debug false
```

This directly renames your original files without creating copies. It's much faster and doesn't require extra disk space, but you cannot undo the operation, so make absolutely certain you have backups before using this mode.

### Processing Only Specific File Types

If you only want to organize videos and ignore photos entirely:

```bash
./rename_files.sh \
  --source "/Users/me/Videos" \
  --target "Camera" \
  --ext "mp4 mov" \
  --rename false \
  --output "renamed_videos"
```

This processes only MP4 and MOV files, leaving all photo formats untouched.

### Processing HEIC and RAW Formats from iPhone

Modern iPhones use HEIC format for photos, and you might have a mix of formats to process:

```bash
./rename_files.sh \
  --source "/Users/me/iPhoneBackup" \
  --target "DCIM" \
  --prefix "IPHONE" \
  --ext "heic jpg png" \
  --rename false \
  --output "organized"
```

This specifically targets HEIC, JPG, and PNG files, adds an "IPHONE" prefix for easy identification, and places results in an "organized" directory.

## 📁 Output Format

Understanding the output format helps you predict exactly what your files will be named. The script creates filenames following this pattern:

```
[PREFIX_]YYYYMMDD_HHMMSS[_SUFFIX][_PANO].extension
```

Let me break down what each component means and show you concrete examples.

The **prefix** appears first if you specified one, followed by an underscore. The **date portion** uses YYYYMMDD format where YYYY is the four-digit year, MM is the two-digit month, and DD is the two-digit day. The **time portion** uses HHMMSS format in 24-hour time. The **suffix** appears before the extension if you specified one. The **PANO marker** is automatically added for MPO (panoramic) files. Finally, the **extension** preserves the original file format.

### Example Transformations

A standard JPEG photo taken on August 14, 2023, at 3:45:30 PM would transform from something like `IMG_1234.jpg` to `20230814_154530.jpg`. The exact moment is captured in the filename, making sorting chronologically trivial.

When processing WhatsApp images with the prefix "WA", that same photo would become `WA_20230814_154530.jpg`, clearly marking its origin while maintaining the chronological information.

If you add a suffix like "backup" to the same photo, it would be named `20230814_154530_backup.jpg`, allowing you to distinguish between different processing batches or purposes.

For panoramic photos in MPO format, the script automatically adds the PANO marker, so `IMG_5678.MPO` becomes `20230814_154530_PANO.MPO`, making it easy to find all your panoramas.

When duplicate timestamps exist (multiple photos taken in the same second), the script appends a counter like `20230814_154530-2.jpg` to ensure unique filenames.

## 🔍 How It Works

Understanding the script's internal logic helps you use it more effectively and troubleshoot any issues. Let me explain the step-by-step process the script follows when processing your files.

**Directory discovery** is the first phase where the script scans your source directory recursively to find all subdirectories matching your target name. It respects the ignore list during this scan, skipping any directories you specified and automatically avoiding output directories to prevent recursive processing issues.

**Date extraction** is where the intelligence happens. For each file found, the script first attempts to read the DateTimeOriginal EXIF tag, which stores when the photo was actually taken. If that tag doesn't exist (common with screenshots or edited images), it falls back to the FileModifyDate. This two-stage approach ensures the script can handle virtually any media file.

**Filename date detection** activates when you have use_date_name enabled. The script searches the original filename for an 8-digit date pattern like "20230814" and extracts it. This recognizes common naming conventions from various camera apps and messaging services.

**Date validation** compares the filename date against the EXIF date when both exist. If they differ by more than 180 days, the script assumes the filename is more trustworthy (perhaps the EXIF data was corrupted during a transfer or edit) and updates the EXIF metadata to match the filename date. This threshold of 180 days was chosen to avoid false positives from timezone differences while catching genuinely incorrect dates.

**Format string construction** builds the new filename using your specified prefix, the extracted date in YYYYMMDD_HHMMSS format, your specified suffix, and the special PANO marker for MPO files. The script uses ExifTool's powerful date formatting capabilities to ensure consistent output.

**File operation** depends on your chosen mode. In copy mode, ExifTool creates a renamed copy in the output directory while leaving the original untouched. In rename mode, ExifTool modifies the original file's name directly with the overwrite_original flag, which is faster but permanent.

**Progress tracking** keeps you informed throughout the process, showing which directory is being processed, how many files were found, and the progress percentage for each directory. Debug mode adds even more detail, showing the exact ExifTool commands being executed and their results.

## 🛡️ Safety Features

The script incorporates several safety mechanisms to protect your precious photo collection from accidental loss or damage.

**Copy mode by default** means the script never touches your original files unless you explicitly enable rename mode. This "safe by default" philosophy ensures you can't accidentally destroy your only copy of irreplaceable photos.

**Automatic output directory exclusion** prevents the script from processing files it has already renamed. If you accidentally run the script twice on the same source, it won't process files in the "renamed" directory again, avoiding infinite recursion and wasted time.

**Comprehensive error handling** means the script checks for missing dependencies, validates input directories exist, and gracefully handles files with corrupt or missing EXIF data rather than crashing halfway through processing thousands of files.

**Progress indicators** let you monitor the script's operation in real time, so if something seems wrong (like processing far more or fewer files than expected), you can interrupt the operation before it completes.

**Debug mode** enables you to see exactly what the script is doing before committing to any operation. Run your first few test batches with debug enabled to verify the behavior matches your expectations.

## ⚠️ Important Warnings

While the script is designed to be safe, there are situations where you need to exercise caution.

**Rename mode is permanent** and cannot be undone. Once you rename files in place, the original names are lost forever. Always test with copy mode first using a small subset of your files. Only switch to rename mode once you're absolutely certain the output is what you want.

**EXIF data modification** occurs when the script detects inconsistent dates between filenames and metadata. While this feature is helpful for fixing corrupt data, it does permanently alter the EXIF information. If you need to preserve original EXIF data in all cases, set `--use_date_name false` to disable this behavior.

**Large collections take time** because ExifTool needs to read metadata from every single file. Processing tens of thousands of photos might take hours, especially in copy mode where file data is being duplicated. Don't interrupt the script while it's running, as this might leave partially processed directories.

**Disk space requirements** for copy mode are significant—you need at least as much free space as the total size of files being processed. Always check your available disk space before processing large collections.

**Network drives can be slow** because reading EXIF data over a network connection is much slower than local disk access. Consider copying files to a local drive for processing if performance is a concern.

**Not tested in corner cases**: In extreme cases such as lack of disk space or with any date format in the name.

## 🐛 Troubleshooting

Let me address common issues you might encounter and how to resolve them.

**No directories found** happens when the script can't locate any folders matching your target name. Use debug mode and verify the target directory name exactly matches what's in your file system (including case sensitivity). Check that your source path is correct and that you're not accidentally ignoring the directories you want to process.

**Files not being processed** might occur if the file extensions don't match your specified list. Remember that extensions are case-insensitive, but you need to explicitly list all variants you want to process. Use debug mode to see which files are being found and which are being skipped.

**ExifTool errors** typically indicate missing or corrupt EXIF data. The script handles these gracefully by falling back to file modification dates, but if you see many errors, some of your files might have serious metadata problems. Try running ExifTool manually on a problem file to diagnose the specific issue.

**Duplicate filenames** happen when multiple photos have identical timestamps. The script automatically appends counters like "-2", "-3" to create unique names. This is normal behavior when processing burst photos or rapidly captured sequences.

**Permission denied errors** mean the script doesn't have rights to read source files or write to the output directory. Check file permissions and make sure you have write access to the parent directory of your output location.

## 🤝 Contributing

Contributions to improve the script are welcome and appreciated. The project follows standard open-source contribution practices.

When submitting issues, please include your operating system, ExifTool version, the exact command you ran, and any error messages. This information is crucial for reproducing and fixing problems.

For pull requests, maintain the existing code style and add comments explaining the reasoning behind any complex logic. Consider adding examples to the README if your contribution introduces new features or changes existing behavior.

Test your changes with various file types and directory structures before submitting. The script needs to work reliably across different real-world scenarios.

## 📄 License

This project is released under the MIT License, which means you're free to use, modify, and distribute it for any purpose, including commercial applications. The only requirement is that you include the original license text with any copies or substantial portions of the software.

## 🙏 Acknowledgments

This script was built on the shoulders of giants. [ExifTool](https://exiftool.org/) by Phil Harvey is the foundation that makes all of this possible—it's an incredibly powerful and reliable tool that handles the complex task of reading and writing EXIF metadata across hundreds of file formats.

The script was created out of personal necessity after struggling to consolidate years of family photos from multiple phones, cloud services, and backups. The frustration of having the same vacation photo appear five times with five different names motivated the creation of a tool that solves this problem once and for all.

## 📞 Support

If you encounter issues or have questions that aren't covered in this README, please open an issue on GitHub with as much detail as possible about your situation. The community and maintainers will do their best to help you resolve the problem.

For general usage questions or to share your success stories, feel free to start a discussion in the GitHub Discussions section. Learning how others use the tool helps improve it for everyone.
