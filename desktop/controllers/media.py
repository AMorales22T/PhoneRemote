import logging
from pynput.keyboard import Controller as KeyboardController, Key
import ctypes
from comtypes import CLSCTX_ALL
from pycaw.pycaw import AudioUtilities, IAudioEndpointVolume

logger = logging.getLogger(__name__)

class MediaController:
    def __init__(self):
        self.keyboard = KeyboardController()
        self._volume_interface = None

    def _get_volume_interface(self):
        """Get the pycaw volume interface lazily."""
        if not self._volume_interface:
            try:
                devices = AudioUtilities.GetSpeakers()
                interface = devices.Activate(
                    IAudioEndpointVolume._iid_, CLSCTX_ALL, None)
                self._volume_interface = ctypes.cast(
                    interface, ctypes.POINTER(IAudioEndpointVolume))
            except Exception as e:
                logger.error(f"Failed to initialize pycaw volume interface: {e}")
        return self._volume_interface

    def play_pause(self):
        """Toggle media play/pause."""
        self.keyboard.tap(Key.media_play_pause)

    def next_track(self):
        """Next media track."""
        self.keyboard.tap(Key.media_next)

    def prev_track(self):
        """Previous media track."""
        self.keyboard.tap(Key.media_previous)

    def volume_up(self):
        """Increase system volume slightly."""
        self.keyboard.tap(Key.media_volume_up)

    def volume_down(self):
        """Decrease system volume slightly."""
        self.keyboard.tap(Key.media_volume_down)

    def mute(self):
        """Toggle system mute."""
        self.keyboard.tap(Key.media_volume_mute)

    def set_volume(self, level: float):
        """Set volume to an absolute percentage (0.0 to 1.0 or 0 to 100)."""
        try:
            # Normalize to 0.0 - 1.0
            if level > 1.0:
                level = level / 100.0
            level = max(0.0, min(1.0, level))
            
            vol = self._get_volume_interface()
            if vol:
                vol.SetMasterVolumeLevelScalar(level, None)
        except Exception as e:
            logger.error(f"Error setting volume: {e}")

    def get_volume(self) -> int:
        """Get current volume percentage (0-100)."""
        try:
            vol = self._get_volume_interface()
            if vol:
                scalar = vol.GetMasterVolumeLevelScalar()
                return int(scalar * 100)
        except Exception as e:
            logger.error(f"Error getting volume: {e}")
        return 50 # Default fallback

    def fullscreen(self):
        """Press F11 for fullscreen toggle."""
        self.keyboard.tap(Key.f11)
