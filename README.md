# rogert - bloated and minimal clipboard management in i3wm

I missed the functionality of a clipboard manager I used to use on windows called, [ClipJump]. So i hacked this stuff together.

These are features that i really liked about ClipJump:
1. Use a notification/popup to preview the clips without stealing focus from currently active window.
2. Navigate the clipboard history with Ctrl+v and Ctrl+c
3. Selecting clip by releasing the control key.

So this is my attempt at getting a similar clipboard experience.

## installation

Clone this repo and `sudo make install` .

## usage

Using a notification, is easy with `dunst` using the `--replace` option to "recycle" the notification. I couldn't find a reliable way to react on the release of the control (or other modifier) key without losing focus of the current window, so i gave up on that. If losing focus is ok, one can use `xev` to do this. Another issue when keeping the window focused is that the keys pressed will get sent to the window, and the best way to block input was to use a [binding mode] in `i3wm`.

[binding mode]: https://i3wm.org/docs/userguide.html#binding_modes
So I added the following to my i3 configuration:

```
bindsym Mod4+v exec --no-startup-id rogert

mode "rogert" { 
  bindsym Escape mode "default" 
  bindsym Mod4+z exec --no-startup-id true
  bindsym Mod4+x exec --no-startup-id true
  bindsym Mod4+c exec --no-startup-id true
  bindsym Mod4+v exec --no-startup-id true
  bindsym Mod4+b exec --no-startup-id true
  bindsym z exec --no-startup-id true
  bindsym x exec --no-startup-id true
  bindsym c exec --no-startup-id true
  bindsym v exec --no-startup-id true
  bindsym b exec --no-startup-id true  
}
```

* <key>Super</key>+<key>v</key> is execute the **rogert.sh** script, which enters the binding mode and displays the last clipboard entry in a notification.
* <key>Esc</key> is a panic button to get back to default binding mode., if the script would fail for some reason.
* <key>v</key> display the next clip in the history.
* <key>c</key> display the previous clip in the history.
* <key>z</key> cancel selection.
* <key>x</key> select the clip currently being displayed. 
* <key>b</key> delete the clip currently being displayed, and view next.

When **rogert** is started it will enter an "event loop" and listen for keybindings. This is why all keybindings except <key>Esc</key> just execute the command: `true`. The actual actions are triggered in from the script in the event loop. Doing it this way, it is easy to keep track on which clip in the history we are currently viewing and no need to parse all the files every time the script is invoked. The reason for mirroring the keybindings in the mode, is so that they will work both with or without holding the modifier (<key>Super</key>). 

## clipboard history

I found a python script made by Byte Commander on [askubuntu.com], that could log clipboard events. I modified it slightly to store each clip in individual files named with the md5 checksum of the content of the clip in: `/tmp/rogert/`, ignoring clips with only white space. Since the filenames are unique to each clip, this made duplication checking automagic. The script do however use the GTK-python bindings (`gi`), and is somewhat bloated (uses ~40MB RAM), but it works really well and both Clipboard and Primary selection is captured. I start [cliplog.py] in `.xinitrc`.

## pasting

When a clip is selected (the <key>x</key> is pressed), the default binding mode is activated and the selected clip is put into the clipboards with `xclip`. Depending on the class of the current window different paste actions are taken. If **Sublime** is active, i use `subl --command 'paste_and_indent'`, to paste with formatting and indentation. Otherwise <key>Shift</key>+<key>Insert</key> is sent with `xdotool` if `URxvt` (a terminal) is active, other wise i send <key>Ctrl</key>+<key>v</key>.

## dependencies

- i3wm, initially i wanted to make a windowmanager agnostic version, but as i mention, i couldn't find a good way to block input from the keyboard.
- dunst
- jq used to parse the keybining events
- xclip, this can easily be replaced with your clipboard cli tool of choice
- python 3.5> + gi (gtk-python bindings)
- GTK 3 , for the python stuff to work
- xdotool to send keystrokes

so, yeah, quite a lot of crap for this to work, but I had all of them installed, python + GTK is often a dependency for other programs. 



[askubuntu.com]: https://askubuntu.com/a/942280
