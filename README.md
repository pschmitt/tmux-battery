# Tmux battery status for OSX

Displays battery percentage and an icon in Tmux status-right. Plug-n-play
installation, enables customization.

Battery full:<br/>
![battery full](/screenshots/battery_full.png)

Battery discharging, custom discharge icon:<br/>
![battery discharging, custom icon](/screenshots/battery_discharging.png)

Battery charging:<br/>
![battery charging](/screenshots/battery_charging.png)

### Manual Installation

Clone the repo:

    $ git clone https://github.com/bruno-/tmux_battery_osx ~/clone/path

Add this line to the bottom `.tmux.conf`:

    run-shell ~/clone/path/battery_osx.tmux

Reload TMUX environment:

    # type this in terminal
    $ tmux source-file ~/.tmux.conf

You should now see battery icon and a percentage in Tmux status-right.

### Installation with [Tmux Plugin Manager](https://github.com/bruno-/tpm)

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @tpm_plugins "              \
      bruno-/tpm                       \
      bruno-/tmux_battery_osx          \
    "

Hit `prefix + I` to fetch the plugin and source it.

Battery icon and percentage should now be visible.

### Configuration

By default `tmux_battery_osx` just adds battery icon and percentage to the
beginning of Tmux status-right.

If you want to customize the display, 2 new "interpolation values" are added:

 - `&bp` - this string in 'status-right' will display battery percentage
 - `&bi` - will display battery icon

Examples:

    set -g status-right "icon: &bi percentage: &bp"
    # or
    set -g status-right "Batt: &bi &bp | %a %h-%d %H:%M "

### Changing icons

By default, these icons are displayed:

 - charged: ":battery:"
 - charging: ":zap:"
 - discharging: (nothing shown)

You can change these defaults by adding the following to `.tmux.conf` (the
following lines are not in the code block so that emojis can be seen):

 - set-option -g @batt_charged_icon ":sunglasses:"
 - set-option -g @batt_charging_icon ":+1:"
 - set-option -g @batt_discharging_icon ":thumbsdown:"

Reminder: OSX allows you to insert various emojis by pressing `Cmd+Ctrl+Space`.

Don't forget to reload TMUX environment (`$ tmux source-file ~/.tmux.conf`)
after you do this.

### License

[MIT](LICENSE.md)
