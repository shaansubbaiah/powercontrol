<center> 
<h1> ⚡powercontrol </h1>
💻 Shell script to control power and battery settings on the Lenovo Ideapad
</center>

Tested on the Ideapad 14ARE05 Ryzen 7 4700U (Should work on the Ideapad 14ARE05, 15ARE05 models).

Built using information from the [Arch Wiki](https://wiki.archlinux.org/index.php/Lenovo_IdeaPad_5_14are05#Tips_and_tricks)

```
- POWERCONTROL ----------
  Shell script to control power and battery settings on the Lenovo IdeaPad 14ARE05, 15ARE05.

  Usage:
    powercontrol [OPTIONS]

  Options:
    -i, --info              Display current power mode and battery status
    -r, --rapid-charge      Toggle Rapid Charge
    -c, --battery-conserve  Toggle Battery Conservation (Doesn't charge >60%)
    -m, --mode [value]     Switch power mode, values:
                              1 - Battery Saving, 2 - Intelligent Cooling, 3 - Extreme Performance
    -h, --help              View this help page
```

Comes with **ABSOLUTELY NO WARRANTY, LIABILITY** if your device gets damaged. Obviously. MIT.
