import sublime
import sublime_plugin

import os
import psutil
import subprocess
import time

class ShellStatusListener(sublime_plugin.EventListener):
    def on_activated_async(self, view):
        battery = psutil.sensors_battery()

        plugged = "↑" if battery.power_plugged else "↓"
        battery_str = '%s %d%%' % (plugged, battery.percent)

        time_str = time.strftime('%H:%M | %d %b')

        view.set_status('AAAAcustom_status', battery_str + ' | ' + time_str)
