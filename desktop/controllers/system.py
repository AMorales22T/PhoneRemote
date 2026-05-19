import logging
import subprocess
import ctypes
import webbrowser

logger = logging.getLogger(__name__)

class SystemController:
    def open_app(self, app_name: str):
        """Open common apps or URLs."""
        app_name = app_name.lower().strip()
        urls = {
            'youtube': 'https://www.youtube.com',
            'netflix': 'https://www.netflix.com',
            'spotify': 'https://open.spotify.com'
        }
        
        try:
            if app_name in urls:
                webbrowser.open(urls[app_name])
            else:
                logger.warning(f"Unknown app to open: {app_name}")
        except Exception as e:
            logger.error(f"Error opening app '{app_name}': {e}")

    def sleep_pc(self):
        """Put the Windows PC to sleep."""
        try:
            # 0=Standby, 1=Force, 0=DisableWakeEvent
            subprocess.run("rundll32.exe powrprof.dll,SetSuspendState 0,1,0", shell=True)
        except Exception as e:
            logger.error(f"Error sleeping PC: {e}")

    def screen_off(self):
        """Turn off the monitors."""
        try:
            # HWND_BROADCAST = 0xFFFF
            # WM_SYSCOMMAND = 0x0112
            # SC_MONITORPOWER = 0xF170
            # Power Off = 2
            ctypes.windll.user32.SendMessageW(0xFFFF, 0x0112, 0xF170, 2)
        except Exception as e:
            logger.error(f"Error turning off screen: {e}")

    def clipboard_get(self) -> str:
        """Get text from Windows clipboard."""
        try:
            import tkinter as tk
            root = tk.Tk()
            root.withdraw()
            text = root.clipboard_get()
            root.destroy()
            return text
        except Exception as e:
            logger.error(f"Error getting clipboard: {e}")
            return ""

    def clipboard_set(self, text: str):
        """Set text to Windows clipboard."""
        try:
            import tkinter as tk
            root = tk.Tk()
            root.withdraw()
            root.clipboard_clear()
            root.clipboard_append(text)
            root.update() # necessary to keep clipboard after destroy
            root.destroy()
        except Exception as e:
            logger.error(f"Error setting clipboard: {e}")
