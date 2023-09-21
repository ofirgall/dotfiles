Hooks for docking/undocking and closing/opening the laptop lid.

NOTE: there are dependencies for the user (ofirg) at `actions` script

## Usage
```sh
./link.sh dell # Links events_dell to /etc/acpi/events/ and links actions to /etc/acpi/actions/
```

## Help
To see acpi events:
```sh
sudo acpi_listen
```

Use `logger` command to send logs like this:
```
event=ac_adapter ACPI0003:00 00000080 00000001
action=logger %e
```

Restart `acpid` service after changing events
```sh
sudo systemctl restart acpid.service
```
