<div align="center">
  <h1>staman(-ager)</h1>
  <img src="https://raw.githubusercontent.com/f1yn/statman/main/.github/example.png" width="30%" height="100%">
</div>

**statman(-ager)** is a simple (Linux only) bash-based script for showing system-statics, media metadata, and whatever else you might want to use. I don't like status bars in my personal environments.
It's intended to run in a fixed terminal window that a Linux desktop environment would load at start, ideally without any resize or decoration support.

The default terminal it's rendered for is 

I've written this script to work on latest Fedora (38+), so you might need to modify some of the commands to compensate for this.

## Features:
- It's written in `bash`, easily modified for your needs. No need to build, or rely on some person's binary blob.
- No dependencies on any fancy curses libraries
- Support for direct rendering and lazy rendering modes, allowing you to test your changes

## Downsides (or things to be aware of):
- It does not support active resizing. It's possible to add, but for simplicity most sizing information is only declared once in `shared.sh`. Statman is meant to be run 
- You're expected to only run a single statman instance on a machine. It uses the shared `/dev/shm` memory store for pushing rendering to prevent needless disk writes. During more than one instance would causes potential conflicts to the memstore.


## Installation

Clone the repository to some place you'd like it to stay.

### Dependencies

The default scripts assume that you have the following installed:
```sh
bash
grep
awk
bc # Used for floating point math in most shell environments, it takes a little getting used to
playerctl # used to get metadata for currently playing music
pactl # used to get the current pipewire master volume
dig # used to fetch public IP
dnf # shows pending system updates
```

`dnf` is system dependant (Fedora/RHEL), so you might want to swap the corresponding script to run something else.

## Running
Before you run this, you should want to pick a terminal that supports decoration removal, or a window manager/compositor that will allow this for you. Doing this will allow statman to render as if it were a non-resizable widget on the desktop.

On your start sequence, just add the following:

```sh
your_terminal_app ./PATH_TO_STATMAN/statman.sh >/dev/null 2>&1 &
```

> **Important!** Please configure your terminal/window manager of choice (likely using a custom config) so it renders the window without decorations. Having it show up as a normal window will not allow it to work as intended. If you're looking for a good Wayland emulator, foot is a good once. I've also included a custom config for foot in the examples directory

## Customizing

### Before you customize

If you start statman with `STATMAN_EXEC_RENDER=1` as a flag, it will render in lazy mode, making it easier to see your changes in real time. It's recommended you keep this option off if you aren't actively making changes.

### Adding new commands

Each script in `/every` corresponds to a specific invocation period in a human readable format. For instance, as you can likely guess `./every/second.sh` is executed every second, and so forth.

Within each of these scripts, are functions. And at the bottom of each are one of commands that resemble the following:

```sh
command_to_file "some-name" "$(some_function)"
```

**`command_to_file` is responsible for rendering the output of the file into the shared system memory store, allowing it to be rendered by statman.** Instead of running all the commands in a single thread, this allows each interval (1s, 2s, 60s, e.c.t) to run in it's own thread. When adding new features, it's important to make sure that `some-name` does not already conflict with another statman name, which you can find by looking for `command_to_file` in the `/every` directory. The corresponding function you create needs to output to stdout, otherwise it wont be captured in the render.

**After declaring a new `command_to_file`, you'll need to update `render.sh` with the new name you've provided. You would simply add a line to the function `render` that would look like (or do the same as):

```sh
cat "$o/some-name"
```

This will attach the memstore output of `some-name` to the output of statman.

### Command helpers

- `$columns` is available in each `/every` script, and represents the current width of the terminal according to `tput`. This is helpful if you want text or elements to change if you decide you want the statman instance to render larger or smaller.
- `bar [char_width] [percent_as_decimal]` is a progress-bar helper that will render a floating point percentage into a text-based progress bar. This is useful for monitoring resources like CPU, memory, or every things like volume.

My default `/every` scripts have examples of how this is used.

## Security considerations (and other things you should know)
- `/dev/shm` is a user writable share in most linux distributions. When a sub directory is created for the statman init sequence, the directory is created using default folder permissions for that user. **This means that any users belonging to the correct groups, or if user
permissions are too permissive by default - other (non-root) users may be able to read your statman contents.**
  On Fedora (38+) I can confirm that the security defaults are sane, but on other more manual distributions or other operating systems this may not be the case. I suggest reviewing the folder permissions and making adjustments as needed.
- The execution of statman does two things. First it spawns several sub-shells solely responsible for running the scripts in the `/every` directory via `runtime.sh`. Then, in the parent calling script, it will start a forever loop that simply renders the contents of `render.sh`.
  The former `runtime.sh` creates subshells, and each subshell will simply reload the contents of the corresponding `/every` script and execute that. **If you need increased assurance that unwanted code wont be executing, changing the permissions of these files to read and execute only. You could do this by running `chmod 550 -R ./statman`**
- If you hate the idea of having this bash script looping in your session in the same namespaces, you could always create a new user specifically for this script. If that's too much, go install `waybar` or just use Gnome.

