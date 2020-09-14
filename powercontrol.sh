#!/bin/sh
# Power control for Ideapad 14ARE05, 15ARE05
# by Shaan Subbaiah

# Built using https://wiki.archlinux.org/index.php/Lenovo_IdeaPad_5_14are05#Tips_and_tricks

# Check if acpi_call is loaded
if ! lsmod | grep -q acpi_call; then
    echo "Error: acpi_call module not loaded"
    exit
fi

# Set it to Intelligent Cooling mode:
#  $ echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x000FB001' | sudo tee /proc/acpi/call

# Set it to Extreme Performance mode:
#  $ echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0012B001' | sudo tee /proc/acpi/call

# Set it to Battery Saving mode:
#  $ echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC 0x0013B001' | sudo tee /proc/acpi/call

get_batteryconserve() {
    # Turn on:
    # $ echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x03' | sudo tee /proc/acpi/call

    # Turn off:
    # $ echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x05' | sudo tee /proc/acpi/call

    echo '\_SB.PCI0.LPC0.EC0.BTSG' | sudo tee /proc/acpi/call
    btsg=$(sudo cat /proc/acpi/call | cut -d '' -f1)

    if [ $btsg == 0x0 ]; then
        batteryconserve="Off"
    elif [ $btsg == 0x1 ]; then
        batteryconserve="On"
    fi

    echo BatteryConservation: $batteryconserve
}

get_rapidcharge() {
    #  Turn on:
    #  $ echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x07' | sudo tee /proc/acpi/call

    # Turn off:
    #  $ echo '\_SB.PCI0.LPC0.EC0.VPC0.SBMC 0x08' | sudo tee /proc/acpi/call

    echo '\_SB.PCI0.LPC0.EC0.FCGM' | sudo tee /proc/acpi/call
    fcgm=$(sudo cat /proc/acpi/call | cut -d '' -f1)

    if [ $fcgm == 0x0 ]; then
        rapidcharge="Off"
    elif [ $fcgm == 0x1 ]; then
        rapidcharge="On"
    fi

    echo RapidCharge: $rapidcharge
}

get_mode() {
    echo '\_SB.PCI0.LPC0.EC0.STMD' | sudo tee /proc/acpi/call
    stmd=$(sudo cat /proc/acpi/call | cut -d '' -f1)

    echo '\_SB.PCI0.LPC0.EC0.QTMD' | sudo tee /proc/acpi/call
    qtmd=$(sudo cat /proc/acpi/call | cut -d '' -f1)

    echo 'qtmd:' $qtmd 'stmd:' $stmd

    if [ $qtmd == 0x0 ] && [ $stmd == 0x0 ]; then
        mode="Extreme Performance"
    elif [ $qtmd == 0x1 ] && [ $stmd == 0x0 ]; then
        mode="Battery Saving"
    elif [ $qtmd == 0x0 ] && [ $stmd == 0x1 ]; then
        mode="Intelligent Cooling"
    fi

    echo Mode: $mode
}

echo "
    -- PowerControl Menu --
"

get_mode

get_rapidcharge

get_batteryconserve
