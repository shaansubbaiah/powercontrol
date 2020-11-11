#!/bin/sh

# Power control for Ideapad 14ARE05, 15ARE05
# by Shaan Subbaiah

# Built using information from the Arch Wiki
# https://wiki.archlinux.org/index.php/Lenovo_IdeaPad_5_14are05#Tips_and_tricks

toggle_batteryconserve() {
    if [ "$batteryconserve" = "On" ]; then
        echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' >/proc/acpi/call
    elif [ "$batteryconserve" = "Off" ]; then
        echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x03' >/proc/acpi/call
    else
        echo 'Something went wrong, exiting :('
        exit 1
    fi

    # Delay reading back the new state, or else the old state will be reported.
    # Required since BIOS version DTCN20WW(V1.06) on the IdeaPad 14ARE05.
    sleep 0.01

    get_batteryconserve
    echo "Set Battery Conservation [$batteryconserve]"
}

toggle_rapidcharge() {
    if [ "$rapidcharge" = "On" ]; then
        echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' >/proc/acpi/call
    elif [ "$rapidcharge" = "Off" ]; then
        echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x07' >/proc/acpi/call
    else
        echo 'Something went wrong, exiting :('
        exit 1
    fi

    get_rapidcharge
    echo "Set Rapid Charge [$rapidcharge]"
}

get_batteryconserve() {
    echo '\_SB.PCI0.LPC0.EC0.BTSG' >/proc/acpi/call
    btsg=$(cat /proc/acpi/call | cut -d '' -f1)

    if [ "$btsg" = 0x0 ]; then
        batteryconserve="Off"
    elif [ "$btsg" = 0x1 ]; then
        batteryconserve="On"
    fi

    # echo BatteryConservation: $batteryconserve
}

get_rapidcharge() {
    echo '\_SB.PCI0.LPC0.EC0.FCGM' >/proc/acpi/call
    fcgm=$(cat /proc/acpi/call | cut -d '' -f1)

    if [ "$fcgm" = 0x0 ]; then
        rapidcharge="Off"
    elif [ "$fcgm" = 0x1 ]; then
        rapidcharge="On"
    fi

    # echo RapidCharge: $rapidcharge
}

get_mode() {
    echo '\_SB.PCI0.LPC0.EC0.STMD' >/proc/acpi/call
    stmd=$(cat /proc/acpi/call | cut -d '' -f1)

    echo '\_SB.PCI0.LPC0.EC0.QTMD' >/proc/acpi/call
    qtmd=$(cat /proc/acpi/call | cut -d '' -f1)

    # echo 'qtmd:' "$qtmd" 'stmd:' "$stmd"

    if [ "$qtmd" = 0x0 ] && [ "$stmd" = 0x0 ]; then
        mode="Extreme Performance"
    elif [ "$qtmd" = 0x1 ] && [ "$stmd" = 0x0 ]; then
        mode="Battery Saving"
    elif [ "$qtmd" = 0x0 ] && [ "$stmd" = 0x1 ]; then
        mode="Intelligent Cooling"
    fi

    # echo Mode: "$mode"
}

switch_mode() {
    case $mode_val in
    1)
        echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' >/proc/acpi/call
        ;;
    2)
        echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' >/proc/acpi/call
        ;;
    3)
        echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' >/proc/acpi/call
        ;;
    *)
        echo "Mode $mode_val is invalid!" >&2
        echo "
        Options :
            1 - Battery Saving, 2 - Intelligent Cooling, 3 - Extreme Performance
        "
        exit 1
        ;;
    esac

    get_mode
    echo "Set Mode [$mode]"
}

display_info() {
    echo "
    $mode
    Battery Conservation [$batteryconserve]
    Rapid Charge         [$rapidcharge]
    "
}

usage() {
    echo "
- POWERCONTROL ----------
  Shell script to control power and battery settings on the Lenovo IdeaPad 14ARE05, 15ARE05.
  
  Usage:
    powercontrol [OPTIONS]

  Options:
    -i, --info              Display current power mode and battery status
    -r, --rapid-charge      Toggle Rapid Charge
    -c, --battery-conserve  Toggle Battery Conservation (Doesn't charge >60%)
    -m, --mode [value]      Switch power mode, values:
                              1 - Battery Saving, 2 - Intelligent Cooling, 3 - Extreme Performance
    -h, --help              View this help page
"
}

# ------------------
#
# PowerControl start
#
# ------------------

# Check if root
if [ "$(id -u)" != "0" ]; then
    echo "This script must run as root!" >&2
    exit 1
fi

# Load acpi_call module
if ! modprobe acpi_call; then
    echo "Error: acpi_call module could not be loaded!" >&2
    exit 1
fi

# Display usage if no args are supplied
if [ -z "$1" ]; then
    usage
    exit 1
fi

# Get current settings
get_mode
get_batteryconserve
get_rapidcharge

# Handle arguments
for arg in "$@"; do
    case $arg in
    -i | --info)
        display_info
        shift
        ;;
    -r | --rapid-charge)
        toggle_rapidcharge
        shift
        ;;
    -c | --battery-conserve)
        toggle_batteryconserve
        shift
        ;;
    -m | --mode)
        mode_val=$2
        switch_mode
        exit 0
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        echo "$1 is an invalid command!"
        usage
        exit 1
        ;;
    esac
done

exit 0
