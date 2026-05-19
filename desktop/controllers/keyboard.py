import logging
from pynput.keyboard import Controller, Key

logger = logging.getLogger(__name__)

class KeyboardController:
    def __init__(self):
        self.keyboard = Controller()
        
        # Map common string keys to pynput Key enum
        self.special_keys = {
            'enter': Key.enter,
            'return': Key.enter,
            'backspace': Key.backspace,
            'tab': Key.tab,
            'escape': Key.esc,
            'esc': Key.esc,
            'space': Key.space,
            'delete': Key.delete,
            'up': Key.up,
            'down': Key.down,
            'left': Key.left,
            'right': Key.right,
            'ctrl': Key.ctrl,
            'alt': Key.alt,
            'shift': Key.shift,
            'win': Key.cmd,
            'cmd': Key.cmd,
            'f1': Key.f1, 'f2': Key.f2, 'f3': Key.f3, 'f4': Key.f4,
            'f5': Key.f5, 'f6': Key.f6, 'f7': Key.f7, 'f8': Key.f8,
            'f9': Key.f9, 'f10': Key.f10, 'f11': Key.f11, 'f12': Key.f12,
        }

    def type_text(self, text: str):
        """Type a string of characters. pynput handles unicode well on Windows."""
        try:
            self.keyboard.type(text)
        except Exception as e:
            logger.error(f"Error typing text '{text}': {e}")

    def press_key(self, key_name: str):
        """Press and release a single key (special or character)."""
        try:
            key_name = key_name.lower()
            key_to_press = self.special_keys.get(key_name, key_name)
            
            # If it's a multi-char string that didn't match a special key, ignore or type
            if isinstance(key_to_press, str) and len(key_to_press) > 1:
                logger.warning(f"Unknown special key: {key_name}")
                return
                
            self.keyboard.press(key_to_press)
            self.keyboard.release(key_to_press)
        except Exception as e:
            logger.error(f"Error pressing key '{key_name}': {e}")

    def hotkey(self, keys_list: list[str]):
        """Press a combination of keys (e.g. ['ctrl', 'c'])."""
        try:
            pressed_keys = []
            # Press all modifiers
            for key_name in keys_list:
                key_name = key_name.lower()
                key_obj = self.special_keys.get(key_name, key_name)
                self.keyboard.press(key_obj)
                pressed_keys.append(key_obj)
                
            # Release in reverse order
            for key_obj in reversed(pressed_keys):
                self.keyboard.release(key_obj)
        except Exception as e:
            logger.error(f"Error executing hotkey {keys_list}: {e}")
