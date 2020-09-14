#!/bin/sh
# Power control for Ideapad 14ARE05, 15ARE05
# by Shaan Subbaiah

# Built using https://wiki.archlinux.org/index.php/Lenovo_IdeaPad_5_14are05#Tips_and_tricks

# Check if acpi_call is loaded
if ! lsmod | grep -q acpi_call; then
    echo "Error: acpi_call module not loaded!" >&2
    exit 1
fi

# Check if root
if [ "$(id -u)" != "0" ]; then
    echo "This script must run as root!" >&2
    exit 1
fi

toggle_batteryconserve() {
    if [ "$batteryconserve" = "On" ]; then
        echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' | sudo tee /proc/acpi/call
    elif [ "$batteryconserve" = "Off" ]; then
        echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x03' | sudo tee /proc/acpi/call
    else
        echo 'Error :('
        exit 0
    fi

    get_batteryconserve
    echo "Set Battery Conservation [$batteryconserve]"
}

toggle_rapidcharge() {
    if [ "$rapidcharge" = "On" ]; then
        echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' | sudo tee /proc/acpi/call
    elif [ "$rapidcharge" = "Off" ]; then
        echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x07' | sudo tee /proc/acpi/call
    else
        echo 'Error :('
        exit 0
    fi

    get_rapidcharge
    echo "Set Rapid Charge [$rapidcharge]"
}

get_batteryconserve() {
    echo '\_SB.PCI0.LPC0.EC0.BTSG' | sudo tee /proc/acpi/call
    btsg=$(sudo cat /proc/acpi/call | cut -d '' -f1)

    if [ "$btsg" = 0x0 ]; then
        batteryconserve="Off"
    elif [ "$btsg" = 0x1 ]; then
        batteryconserve="On"
    fi

    # echo BatteryConservation: $batteryconserve
}

get_rapidcharge() {
    echo '\_SB.PCI0.LPC0.EC0.FCGM' | sudo tee /proc/acpi/call
    fcgm=$(sudo cat /proc/acpi/call | cut -d '' -f1)

    if [ "$fcgm" = 0x0 ]; then
        rapidcharge="Off"
    elif [ "$fcgm" = 0x1 ]; then
        rapidcharge="On"
    fi

    # echo RapidCharge: $rapidcharge
}

get_mode() {
    echo '\_SB.PCI0.LPC0.EC0.STMD' | sudo tee /proc/acpi/call
    stmd=$(sudo cat /proc/acpi/call | cut -d '' -f1)

    echo '\_SB.PCI0.LPC0.EC0.QTMD' | sudo tee /proc/acpi/call
    qtmd=$(sudo cat /proc/acpi/call | cut -d '' -f1)

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

# set_batterysaving() {
#     echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' | sudo tee /proc/acpi/call
#     get_mode
#     echo "Set Mode [$mode]"
# }

# set_intelligentcooling() {
#     echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' | sudo tee /proc/acpi/call
#     get_mode
#     echo "Set Mode [$mode]"
# }

# set_extremeperformance() {
#     echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' | sudo tee /proc/acpi/call
#     get_mode
#     echo "Set Mode [$mode]"
# }

switch_mode() {
    if [ "$mode_val" = 1 ]; then
        echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' | sudo tee /proc/acpi/call
    elif [ "$mode_val" = 2 ]; then
        echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' | sudo tee /proc/acpi/call
    elif [ "$mode_val" = 3 ]; then
        echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' | sudo tee /proc/acpi/call
    fi

    get_mode
    echo "Set Mode [$mode]"
}

display_info() {
    echo "$mode"
    echo "Battery Conservation [$batteryconserve]"
    echo "Rapid Charge         [$rapidcharge]"
}

display_help() {
    echo "you need help"
    exit 1
}

get_mode
get_batteryconserve
get_rapidcharge

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
        if [ "$2" = 1 ] || [ "$2" = 2 ] || [ "$2" = 3 ]; then
            mode_val=$2
            switch_mode
        #       echo set_batterysaving
        # elif [ "$2" = 2 ]; then
        #     echo set_intelligentcooling
        # elif [ "$2" = 3 ]; then
        #     echo set_extremeperformance
        else
            echo "$1 doesn't support option $2" >&2
            exit 1
        fi

        get_mode

        ;;
    -h | --help)
        display_help
        ;;
    esac
done

exit 1
