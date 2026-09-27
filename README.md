# Backup Script

A simple bash script to create timestamped backups with logging and automatic rotation.

## Features

- Creates compressed `.tar.gz` backups with timestamp
- Logs every action with timestamps
- Automatically deletes backups older than N days
- Input validation to prevent common mistakes
- Designed to work with cron for scheduled backups

## Usage

```
./backup.sh <source_dir> <dest_dir> [retention_days]
```

### Arguments

- `source_dir` _ Directory to back up (required)
- `dest_dir` _ Where to store backups, created if missing (required)
- `retention_days` _ Delete backups older than this (default: 7)

### Example

```
./backup.sh /home/user/data /home/user/backups 7
```

### Scheduled with cron

Add this line to `crontab -e`:

```
0 2 * * * /home/user/backup-script/backup.sh /home/user/data /home/user/backups 7 >> /home/user/backups/cron.log 2>&1
```

This runs the backup every dat at 2 AM.

## How it works

1.Validates inputs (source exists, destination is writable, no recursion)
2.Creates a compressed tar.gz archive with timestamp
3.Logs every step to `<dest>/backup.log`
4.Delete old backups based on retention days

## License

MIT
