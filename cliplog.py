#!/usr/bin/env python3

# based on scipt by Byte Commander
# https://askubuntu.com/a/942280

import signal
import hashlib
from pathlib import Path

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk

clipdir = "/tmp/rogert"
Path(clipdir).mkdir(parents=True, exist_ok=True)

signal.signal(signal.SIGINT, signal.SIG_DFL)


def callback(*args):
    paste = clip.wait_for_text()
    if paste != "" or paste.strip():
        md5 = hashlib.md5(paste.encode())
        f = open(clipdir + "/" + md5.hexdigest(), "w")
        f.write(paste)
        f.close()


clip = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
clip.connect('owner-change', callback)
Gtk.main()
